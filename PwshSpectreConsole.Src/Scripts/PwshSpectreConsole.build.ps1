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
    OutputPath       = Join-Path $projectRoot 'output' 'PwshSpectreConsole'
    ModuleSourcePath = Join-Path $projectRoot 'PwshSpectreConsole'
    TestPath         = Join-Path $projectRoot 'PwshSpectreConsole.Tests'
    CsprojPath       = Join-Path $projectRoot 'PwshSpectreConsole.Src' 'PwshSpectreConsole.csproj'
    DotnetOutputPath = Join-Path $projectRoot 'output' 'PwshSpectreConsole' 'lib'
}
function MergePSM1 {
    param(
        $Path
    )
    Write-Host "Merging $($Path)" -ForegroundColor Gray
    $content = Get-Content $Path.FullName -Raw
    '#region {0}' -f ([System.IO.Path]::GetRelativePath($projectRoot, $Path.FullName) -replace '\\','/')
    [Environment]::NewLine
    $content = $content -replace '(?m)^using (module|namespace).*$' -replace '(?m)\r?\n',([Environment]::NewLine)
    $content.Trim()
    [Environment]::NewLine
    '#endregion'
    [Environment]::NewLine
}

task Clean {
    Write-Host "Cleaning output directory: $($script:config.OutputPath)" -ForegroundColor Yellow
    if (Test-Path $script:config.OutputPath) {
        Remove-Item -Path $script:config.OutputPath -Recurse -Force
    }
    $parent = Split-Path $script:config.OutputPath -Parent
    if (!(Test-Path $parent)) {
        New-Item -Path $parent -ItemType Directory | Out-Null
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
        exec { dotnet publish -c $Configuration -o $script:config.DotnetOutputPath }
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
    MergePSM1 -Path (Get-Item (Join-Path $script:config.ModuleSourcePath "$($script:config.ModuleName).psm1")) | Add-Content -Path $MergedPSM1Path -NoNewline
}

task StaticAssets {
    Write-Host "Copying static assets to output directory" -ForegroundColor Yellow
    # Only one needed for the demo at the moment
    $asset = Join-Path $script:config.ModuleSourcePath 'private' 'images' 'smiley.png'
    if (Test-Path $asset) {
        $destination = Join-Path $script:config.OutputPath 'smiley.png'
        Copy-Item -Path $asset -Destination $destination -Force
        Write-Host "Copied asset: $($asset) to $($destination)" -ForegroundColor Green
    } else {
        throw "Asset not found at: $($asset)"
    }
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
    if ($env:CI) {
        $pesterConfig.Filter.ExcludeTag = "ExcludeCI"
    }

    $modulePath = Resolve-Path (Join-Path $script:config.OutputPath "$($script:config.moduleName).psd1")
    Write-Host "Running merged PSM1 tests for module $modulePath..." -ForegroundColor Yellow
    Import-Module $modulePath
    $TestHelpersPath = Resolve-Path (Join-Path $script:config.TestPath 'TestHelpers.psm1')
    Import-Module $TestHelpersPath -ErrorAction Stop

    Invoke-Pester -Configuration $pesterConfig
}

task CleanAfter {
    Write-Host "Cleaning up merged module test artifacts" -ForegroundColor Yellow
    if ($script:config.DotnetOutputPath -and (Test-Path $script:config.DotnetOutputPath)) {
        Get-Childitem $script:config.DotnetOutputPath -File | Where-Object { $_.Extension -in '.pdb', '.json' } | Remove-Item -Force -ErrorAction Ignore
    }
}

task All -Jobs Clean, Build, ModuleFiles, StaticAssets, CleanAfter, Test
task Repro -Jobs Clean, Build, ModuleFiles, StaticAssets, CleanAfter
task TestMerge -Jobs Test
