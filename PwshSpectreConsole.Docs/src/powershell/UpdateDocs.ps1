#requires -Modules HelpOut
param(
    [ValidateSet("dev", "prerelease", "main")]
    [string]$Branch = "dev",
    [switch]$NonInteractive,
    [switch]$NoBuild,
    [switch]$NoCommit,
    [string]$TargetFunction
)

$ErrorActionPreference = "Stop"

# The new version has a bug which is failing this on windows
$helpOut = Get-Module "HelpOut" -ListAvailable
if($helpOut.Version.ToString() -ne "0.5") {
    throw "Must be run with HelpOut v0.5"
}

& "$PSScriptRoot\..\..\..\PwshSpectreConsole\Build.ps1" -NoReinstall

Import-Module "$PSScriptRoot\..\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\Helpers.psm1" -Force
Import-Module "$PSScriptRoot\Mocks.psm1" -Force

# Ignore update tags for these, remove them from the list if they are updated this just makes it easy to bypass the "updated" tag
$ignoreUpdatesFor = @(
    "Format-SpectreBarChart",
    "Format-SpectreBreakdownChart",
    "Format-SpectrePanel",
    "Format-SpectreTable",
    "Get-SpectreDemoEmoji",
    "Start-SpectreDemo",
    "New-SpectreChartItem",
    "Get-SpectreImage",
    "Get-SpectreImageExperimental",
    "Add-SpectreJob",
    "Invoke-SpectreCommandWithProgress",
    "Invoke-SpectreCommandWithStatus",
    "Invoke-SpectreScriptBlockQuietly",
    "Wait-SpectreJobs",
    "Read-SpectrePause",
    "Get-SpectreEscapedText",
    "Set-SpectreColors",
    "Start-SpectreRecording",
    "Stop-SpectreRecording"
)

# Git user details for github action commits
$env:GIT_COMMITTER_NAME = 'Shaun Lawrie (via GitHub Actions)'
$env:GIT_COMMITTER_EMAIL = 'shaun.r.lawrie@gmail.com'

# Stage files in a temp directory to avoid issues with astro running in dev mode locking files
if($IsLinux) {
    $env:TEMP = "/tmp"
}
$outputPath = "$PSScriptRoot/../content/docs/reference/"
$asciiCastOutputPath = "$PSScriptRoot/../assets/examples/"
$stagingPath = "$env:TEMP/refs-staging"
if(Test-Path $stagingPath) {
    Remove-Item $stagingPath -Force -Recurse
}

# Dump branch for debugging github action
Write-Host "Branch is '$Branch'"

# Dump the module help to markdown files
Save-MarkdownHelp -Module "PwshSpectreConsole" -OutputPath $stagingPath -IncludeYamlHeader -YamlHeaderInformationType Metadata -ExcludeFile "*.gif", "*.png"

# First pass to get raw help docs
$docs = Get-ChildItem $stagingPath -Filter "*.md" -Recurse | Where-Object { $_.Name -like "*-*" }
foreach ($doc in $docs) {
    # Generate output paths
    $hashOutLocation = Join-Path $stagingPath ("_" + $($doc.Name -replace '.md$', '.sha256'))

    # Remove carriage returns and trailing newlines and write the file back to make it the same on all platforms
    $content = Get-Content $doc.FullName -Raw
    $content = $content -replace "`r", ""
    Set-Content -Value $content -Path $doc.FullName -NoNewline

    # Get the hash of the new file to compare against in the future for help doc changes
    $contentHash = Get-FileHash $doc.FullName -Algorithm SHA256
    Set-Content -Path $hashOutLocation -Value $contentHash.Hash.Trim() -NoNewline
}

# Update the hash files in git so the modified files can be detected
# I regret doing it this way but cbf changing it now
Update-HashFilesInGit -StagingPath $stagingPath -OutputPath $outputPath -NoCommit:$NoCommit

# Format the files for astro
$docs = Get-ChildItem $stagingPath -Filter "*.md" -Recurse | Where-Object { $_.Name -like "*-*" }
$mocks = Get-Module "Mocks"
if (![string]::IsNullOrEmpty($TargetFunction)) {
    Write-Host "Filtering to only include help for function $TargetFunction"
    $docs = $docs | Where-Object { $_.Name -like "*$TargetFunction*" }
}
foreach ($doc in $docs) {
    $content = Get-Content $doc.FullName -Raw

    # Fix the broken code blocks for astro
    $content = $content -replace '```PowerShell', '```powershell'

    # Remove the command name from the top of the file
    $commandName = $doc.Name -replace ".md",""
    $content = $content -replace "(?m)^.+\n^[\-]{$($commandName.Length)}", ''

    # Remove the synopsis, the description is good enough
    $content = $content -replace "(?ms)^^### Synopsis.+?#", '#'
    
    # Get last modified date of file from git (the path is relative to this file)
    $gitCommitDates = Get-GitCommitDatesForHashFile -Name $doc.Name -OutputPath $outputPath
    $modified = $gitCommitDates | Select-Object -First 1
    $created = $gitCommitDates | Select-Object -Last 1
    $recentThresholdDays = 30

    # Work out the tag to apply to the current help file
    $tag = $null
    if([string]::IsNullOrEmpty($created) -or ((Get-Date) - ([datetime]$created)).TotalDays -lt $recentThresholdDays) {
        $tag = "New"
    } elseif ((((Get-Date) - ([datetime]$modified)).TotalDays -lt $recentThresholdDays) -and $ignoreUpdatesFor -notcontains $commandName) {
        $tag = "Updated"
    }
    Write-Host "File $($doc.Name) was last modified on $modified and created on $created, using tag $tag"
    
    # Add the tag to the top of the file
    if($tag) {
        $tagYaml = Get-Tag -Tag $tag
        $content = $content -replace '(?s)^---', "---`n$tagYaml"
    }

    # Foreach example run the codeblock and record the output as an ascii cast
    $codeBlocks = $content -replace '(?s)### Syntax.+', '' | Select-String -AllMatches '(?s)```powershell.+?```'
    $brokenExamples = @(
        "Start-SpectreDemo.md"
    )

    # If there are codeblocks in the help docs, execute them and record the output for the online help
    if($codeBlocks -and $brokenExamples -notcontains $doc.Name) {
        $codeBlocksExcludingSyntaxSection = $codeBlocks.Matches.Value
        $example = 0
        Push-Location
        try {
            Set-Location $PSScriptRoot
            $imports = "import Asciinema from '../../../../components/Asciinema.astro'`n"
            # Demo colors is annoying and needs a darker foreground color
            if ($doc.Name -like "*DemoColors*") {
                $imports = "<style>{`` div.asciinema-player-theme-spectre { --term-color-0: #000000; } ``}</style>`n`n" + $imports
            }
            foreach($codeBlock in $codeBlocksExcludingSyntaxSection) {
                $code = $codeBlock -replace '(?s)```powershell', ''
                $code = $code -replace '```', ''
                $code = $code.Trim()

                # Extract the input comments
                $inputs = $code | Select-String '# Type (".+")'
                $specialChars = @("↑", "↓", "↲", "<space>")
                $inputDelay = Get-Random -Minimum 500 -Maximum 1000
                $typingDelay = Get-Random -Minimum 50 -Maximum 200
                $recordingConsole = Start-SpectreRecording -RecordingType "asciinema" -Width 110 -Height 48

                Write-Host "Generating sample for:"
                Write-Host -ForegroundColor DarkGray $code
                Write-Host "Inputs:"
                if($inputs) {
                    $strings = $inputs.Matches.Groups[1].Value.Split(",") | Foreach-Object { $_.Trim() -replace '^"', '' -replace '"$', '' }
                    foreach($string in $strings) {
                        if($specialChars -contains $string -or $string.Length -eq 1) {
                            Write-Host -ForegroundColor DarkGray "PushCharacter '$string'"
                            if($string -eq "<space>") {
                                $recordingConsole.Input.PushKey([System.ConsoleKey]::Spacebar, $inputDelay)
                            } else {
                                $recordingConsole.Input.PushCharacter([char]$string, $inputDelay)
                            }
                        } else {
                            Write-Host -ForegroundColor DarkGray "PushText '$string'"
                            $recordingConsole.Input.PushText($string, $typingDelay)
                        }
                    }
                } else {
                    Write-Host -ForegroundColor DarkGray "None"
                }
                foreach($mock in $mocks.ExportedCommands.Values.Name) {
                    $originalCommandName = $mock -replace "Mock"
                    $code = $code -replace $originalCommandName, $mock
                    $code = $code -replace "function $originalCommandName", "function ${mock}Replaced"
                }
                Write-Host "Modified sample:"
                Write-Host -ForegroundColor DarkGray $code
                if($code -like "*Write-Error*") {
                    $code = $code -replace "Write-Error", "Write-Host"
                }
                Set-Location "$PSScriptRoot/../../../PwshSpectreConsole"
                Push-Location -StackName "ExampleInvoke"
                Invoke-Expression $code
                Set-SpectreColors -AccentColor "Turquoise2"
                Pop-Location -StackName "ExampleInvoke"
                $recording = Stop-SpectreRecording -Title "Example $([int]$example++)"

                $castName = ($doc.Name -replace '.md$', '' -replace '-', '').ToLower() + "Example$example"
                Set-Content -Path "$asciiCastOutputPath\$castName.cast" -Value $recording
                $imports += "import $castName from '../../../../assets/examples/$castName.cast?url'`n"

                # Replace the code block with the ascii cast
                $castTemplate = Get-AsciiCastTemplate -Name $castName
                $content = $content -replace "(?ms)> EXAMPLE $example.+?(``````.+?``````)", "> EXAMPLE $example`n`n`$1`n$castTemplate"
                $content = $content -replace "(?ms)(\*\*Example $example\*\*.+?)(``````.+?``````)", "`n`n`$1`n`n`$2`n$castTemplate"
            }
            $content = $content -replace "### Description", "$imports`n### Description"
        } finally {
            Pop-Location
            [Spectre.Console.AnsiConsole]::Console = $originalConsole
        }
    }
    
    # Write out the formatted file
    $content | Out-File $doc.FullName -NoNewline
}

# Copy the files into the output directory in a way that doesn't crash the astro dev server
Update-HelpFiles -StagingPath $stagingPath -AsciiCastOutputPath $asciiCastOutputPath -OutputPath $outputPath -NoCommit:$NoCommit -TargetFunction $TargetFunction

# Set some overrides to indicate it's the pre-release site
if($Branch -eq "prerelease") {
    $astroConfigPath = "$PSScriptRoot\..\..\astro.config.mjs"
    $astroConfig = Get-Content -Path $astroConfigPath -Raw
    $astroConfig = $astroConfig -replace 'title: "PwshSpectreConsole"', 'title: "PwshSpectreConsole (Pre-release)"'
    Set-Content -Path $astroConfigPath -Value $astroConfig
}

if($NoBuild) {
    return 
}

# Build the docs site
$docsProjectRoot = Join-Path $PSScriptRoot ".." ".."
npm ci --prefix $docsProjectRoot
if ($LASTEXITCODE -ne 0) {
    throw "Failed to install npm dependencies"
}

npm run build --prefix $docsProjectRoot
if ($LASTEXITCODE -ne 0) {
    throw "Failed to run npm build"
}

if ($NonInteractive) {
    return
}

if ($Branch -eq "dev") {
    if(netstat -anot | Select-String ":4321\s.*LISTENING") {
        Write-Host "Astro dev server already running"
    } else {
        npm run dev --prefix $docsProjectRoot
    }
    Start-Process "http://localhost:4321"
} elseif ($Branch -eq "prerelease") {
    # Deploy to preview
    if (npx --yes wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
        Write-Host "Already logged into cloudflare"
    } else {
        npx wrangler login
    }
    npx wrangler pages deploy "$docsProjectRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=prerelease
} elseif ($Branch -eq "main") {
    # Yeet it to cloudflare
    $choice = Read-Host "`nDeploy to Prod CF pages? (y/n)"
    if ($choice -eq "y") {
        if (npx wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
            Write-Host "Already logged into cloudflare"
        } else {
            npx wrangler login
        }
        npx wrangler pages deploy "$docsProjectRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=main
    }
}