#! /usr/bin/pwsh
#Requires -Version 7.4 -Module InvokeBuild
param(
    [string]$Configuration = 'Release',
    [string[]]$FullNameFilter,
    [string]$PesterOutput
)

$projectRoot = Join-Path $PSScriptRoot '..' '..'

Write-Host "$($PSBoundParameters.GetEnumerator())" -ForegroundColor Cyan

$script:config = @{
    ModuleName       = 'PwshSpectreConsole'
    ProjectRoot      = $projectRoot
    SourcePath       = Join-Path $projectRoot 'PwshSpectreConsole.Src'
    OutputPath       = Join-Path $projectRoot 'output'
    ModuleSourcePath = Join-Path $projectRoot 'PwshSpectreConsole'
    TestPath         = Join-Path $projectRoot 'PwshSpectreConsole.Tests'
    CsprojPath       = Join-Path $projectRoot 'PwshSpectreConsole.Src' 'PwshSpectreConsole.csproj'
    DestinationPath  = Join-Path $projectRoot 'output' 'lib'
}
function MergePSM1 {
    param(
        $Path
    )
    $content = Get-Content $Path.FullName -Raw
    '#region {0}' -f ([System.IO.Path]::GetRelativePath($projectRoot, $Path.FullName) -replace '\\','/')
    $content = $content -replace '(?m)^using (module|namespace).*$' -replace '(?m)\r?\n',([Environment]::NewLine)
    $content.Trim()
    '#endregion'
    [Environment]::NewLine
}

task Clean {
    Write-Host "Cleaning output directory: $($script:config.OutputPath)" -ForegroundColor Yellow
    if (Test-Path $script:config.OutputPath) {
        Remove-Item -Path $script:config.OutputPath -Recurse -Force
    }
    New-Item -Path $script:config.OutputPath -ItemType Directory -Force | Out-Null
}

task Build {
    Write-Host "Building C# project: $($script:config.CsprojPath)" -ForegroundColor Yellow
    if (-not (Test-Path $script:config.CsprojPath)) {
        Write-Warning 'C# project not found, skipping Build'
        return
    }
    try {
        Push-Location $script:config.SourcePath
        exec { dotnet publish -c Release -o $script:config.DestinationPath }
    } finally {
        Pop-Location
    }
}

task ModuleFiles {
    Write-Host "Merging PowerShell module files from: $($script:config.ModuleSourcePath)" -ForegroundColor Yellow
    if (-not (Test-Path $script:config.ModuleSourcePath)) {
        Write-Error "Module source directory not found at: $($script:config.ModuleSourcePath)"
        return
    }

    $sourcemodule = Join-Path $script:config.ModuleSourcePath "$($script:config.ModuleName).psd1"
    # Verify module manifest exists
    if (-not (Test-Path $sourcemodule)) {
        Write-Warning "Module manifest not found at: $($sourcemodule)"
        return
    }

    # Copy .psd1 to output
    Get-ChildItem -Path $script:config.ModuleSourcePath -File | Where-Object { $_.Extension -in '.psd1', '.ps1xml' } | Copy-Item -Destination $script:config.OutputPath
    $MergedPSM1Path = Join-Path $script:config.OutputPath "$($script:config.ModuleName).psm1"
    # fix up .psd1
    $psd1 = Get-Childitem $script:config.OutputPath | Where-Object { $_.Extension -eq '.psd1' } | Get-Content -Raw
    $psd1 = $psd1 -replace '(?m)^RootModule.*$', "RootModule = '$($script:config.ModuleName).psm1'"
    $psd1 | Set-Content -Path (Join-Path $script:config.OutputPath "$($script:config.ModuleName).psd1")
    # add using namespaces statements, should automate this in the future..
    @'
using namespace System.Management.Automation
using namespace Spectre.Console
using namespace Spectre.Console.Rendering
using namespace PwshSpectreConsole
'@ | Out-String | Set-Content -Path $MergedPSM1Path -NoNewline

    # Get all the classes
    'completions','models' | ForEach-Object {
        Get-ChildItem (Resolve-Path (Join-Path $script:config.ModuleSourcePath 'private' $_)) -File -Recurse -Include @('*.ps1','*.psm1') | ForEach-Object {
            MergePSM1 -Path $_
        }
    } | Out-String | Add-Content -Path $MergedPSM1Path -NoNewline

    # private functions
    Get-ChildItem (Resolve-Path (Join-Path $script:config.ModuleSourcePath 'private')) -File -Recurse -Include '*.ps1' | ForEach-Object {
        MergePSM1 -Path $_
    } | Out-String | Add-Content -Path $MergedPSM1Path -NoNewline

    # public functions
    Get-ChildItem (Resolve-Path (Join-Path $script:config.ModuleSourcePath 'public')) -File -Recurse -Include '*.ps1' | ForEach-Object {
        MergePSM1 -Path $_
    } | Out-String | Add-Content -Path $MergedPSM1Path -NoNewline

    # Add initialization code
    @'
$script:AccentColor = [Spectre.Console.Color]::Blue
$script:DefaultValueColor = [Spectre.Console.Color]::Grey
$script:DefaultTableHeaderColor = [Spectre.Console.Color]::Default
$script:DefaultTableTextColor = [Spectre.Console.Color]::Default

# For widgets that can be streamed to the console as raw text, prompts/progress widgets do not use this.
# This allows the terminal to process them as text so they can be dumped like:
# PS> $widget = "Hello, World!" | Format-SpectrePanel -Title "My Panel" -Color Blue -Expand
# PS> $widget # uses the default powershell console writer
# PS> $widget > file.txt # redirects as string data to file
# PS> $widget | Out-SpectreHost # uses a dedicated console writer that doesn't pad the object like the default formatter
$script:SpectreConsoleWriter = [System.IO.StringWriter]::new()
$script:SpectreConsoleOutput = [Spectre.Console.AnsiConsoleOutput]::new($script:SpectreConsoleWriter)
$script:SpectreConsoleSettings = [Spectre.Console.AnsiConsoleSettings]::new()
$script:SpectreConsoleSettings.Out = $script:SpectreConsoleOutput
$script:SpectreConsole = [Spectre.Console.AnsiConsole]::Create($script:SpectreConsoleSettings)

# Initialize console dimensions to ensure they're valid (important for CI environments)
Initialize-SpectreConsoleDimensions

# cache the DA1 response.
$script:TerminalSupportsSixel = [PwshSpectreConsole.Terminal.Compatibility]::TerminalSupportsSixel()

$script:SpectreProfile = Get-SpectreProfile
if ($script:SpectreProfile.Unicode -eq $true -or $env:IgnoreSpectreConsoleEncoding) {
    return $script:SpectreConsole
}

if ($env:IgnoreSpectreEncoding -eq $true) {
    return
}
@"
[white]Your terminal host is currently using encoding '$($SpectreProfile.Encoding)' which limits Spectre Console functionality.

To enable UTF-8 output in your terminal, add the following line at the top of your PowerShell `$PROFILE file and restart the terminal:
[Orange1 on Grey15]$('$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()' | Get-SpectreEscapedText)[/]

If you don't want to enable UTF-8, you can suppress this warning with the environment variable [Orange1 on Grey15]`$env:IgnoreSpectreEncoding = `$true[/] instead.

For more details see:
 - https://github.com/ShaunLawrie/PwshSpectreConsole/issues/46
 - https://spectreconsole.net/best-practices#configuring-the-windows-terminal-for-unicode-and-emoji-support
 - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles[/]
"@ | Format-SpectrePanel -Title "[Orange1] PwshSpectreConsole Warning [/]" -Color OrangeRed1 -Expand | Out-Host
'@ | Add-Content -Path $MergedPSM1Path -NoNewline
}

task PSScriptAnalyzer {
    Write-Host "Running PSScriptAnalyzer on merged module" -ForegroundColor Yellow
    # this is just a bit broken, should take a look at it in the future with proper settings.
    # Import-Module PSScriptAnalyzer -ErrorAction Stop
    # $MergedPSM1Path = Join-Path $script:config.OutputPath "$($script:config.moduleName).psm1"
    # $psmfile = Get-Item $MergedPSM1Path
    # $psmContent = Get-Content $psmfile.FullName -Raw
    # Invoke-Formatter -ScriptDefinition $psmContent -Settings CodeFormattingStroustrup -ErrorAction Stop | Set-Content $psmfile.FullName
    # Invoke-ScriptAnalyzer -Path $psmfile.FullName -Recurse -Severity Warning -ErrorAction Stop -IncludeDefaultRules
}

task Test {
    Write-Host "Running tests from: $($script:config.TestPath)" -ForegroundColor Yellow
    if (-not (Test-Path $script:config.TestPath)) {
        Write-Host "    Test directory not found at: $($script:config.TestPath)" -ForegroundColor Yellow
        return
    }
    $splat = @{}
    if ($env:CI) {
        $splat.CI = $true
        $splat.ExcludeTag = "ExcludeCI"
        $env:RunMergedPsm1Tests = $true
    }
    $pesterConfig = New-PesterConfiguration
    $pesterConfig.Run.Path = $script:config.TestPath
    $pesterConfig.Run.Throw = $true
    $pesterConfig.Debug.WriteDebugMessages = $false
    if ($FullNameFilter) {
        $pesterConfig.Filter.FullName = $FullNameFilter
    }
    if ($PesterOutput) {
        $pesterConfig.Output.Verbosity = $PesterOutput
    }

    Write-Host "Running merged PSM1 tests..." -ForegroundColor Yellow
    $env:RunMergedPsm1Tests = $true
    Import-Module (Resolve-Path (Join-Path $script:config.OutputPath "$($script:config.moduleName).psd1"))

    Invoke-Pester -Configuration $pesterConfig @splat
    Remove-Item Env:RunMergedPsm1Tests -ErrorAction Ignore
}

task CleanAfter {
    Write-Host "Cleaning up merged module test artifacts" -ForegroundColor Yellow
    Remove-Item Env:RunMergedPsm1Tests -ErrorAction Ignore
    if ($script:config.DestinationPath -and (Test-Path $script:config.DestinationPath)) {
        Get-Childitem $script:config.DestinationPath -File | Where-Object { $_.Extension -in '.pdb', '.json' } | Remove-Item -Force -ErrorAction Ignore
    }
}

task All -Jobs Clean, Build, ModuleFiles, CleanAfter, Test
task Repro -Jobs Clean, Build, ModuleFiles, CleanAfter
task TestMerge -Jobs Test
