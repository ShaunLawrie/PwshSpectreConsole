#requires -Modules HelpOut
param(
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"

Remove-Module -Name PwshSpectreConsole -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Remove-Item -Recurse -Path "$PSScriptRoot\src\content\docs\reference\*" -Force
$module = Get-Module PwshSpectreConsole

if($null -eq $module) {
    throw "Failed to import PwshSpectreConsole module"
}

$module | Save-MarkdownHelp -OutputPath "$PSScriptRoot\src\content\docs\reference\" -IncludeYamlHeader -YamlHeaderInformationType Metadata -ExcludeFile "*.gif", "*.png"

$new = @("New-SpectreChartItem.md", "Get-SpectreDemoColors.md", "Get-SpectreDemoEmoji.md", "Format-SpectreJson.md", "Write-SpectreCalendar.md", "Format-SpectreJson.md")
$experimental = @("Get-SpectreImageExperimental.md", "Invoke-SpectreScriptBlockQuietly.md")

$newTag = @"
sidebar:
  badge:
    text: New
    variant: tip
"@

$experimentalTag = @"
sidebar:
  badge:
    text: Experimental
    variant: caution
"@

# Post-processing for astro stuff
$groups = @(
    @{ Name = "Prompts"; Matches = @("read-") }
    @{ Name = "Formatting"; Matches = @("format-", "chartitem") }
    @{ Name = "Progress"; Matches = @("invoke-", "job", "spectrescriptblock") }
    @{ Name = "Images"; Matches = @("image") }
    @{ Name = "Writing"; Matches = @("write-", "escaped") }
    @{ Name = "Config"; Matches = @("set-") }
    @{ Name = "Demo"; Matches = @("spectredemo") }
)

$docs = Get-ChildItem "$PSScriptRoot\src\content\docs\reference\" -Filter "*.md" -Recurse
foreach($doc in $docs) {
    if($remove -contains $doc.Name -or $doc.Name -notlike "*-*") {
        Remove-Item $doc.FullName
        continue
    }

    $group = $null
    foreach($testGroup in $groups) {
        foreach($match in $testGroup.Matches) {
            if($doc.Name -like "*$match*") {
                $group = $testGroup
                break
            }
        }
    }

    $outLocation = "$PSScriptRoot\src\content\docs\reference\$($group.Name)\$($doc.Name)"
    if($null -eq $group) {
        $outLocation = $doc.FullName
    }
    New-Item -ItemType Directory -Path "$PSScriptRoot\src\content\docs\reference\$($group.Name)" -Force | Out-Null
    $content = Get-Content $doc.FullName -Raw
    Remove-Item $doc.FullName
    $content = $content -replace '```PowerShell', '```powershell' -replace '(?m)^.+\n^[\-]{10,99}', '' -replace "`r", ""
    if($experimental -contains $doc.Name) {
        $content = $content -replace '(?s)^---', "---`n$experimentalTag"
    } elseif($new -contains $doc.Name) {
        $content = $content -replace '(?s)^---', "---`n$newTag"
    }
    $content | Out-File $outLocation -NoNewline
}

# Build the docs site
npm ci --prefix $PSScriptRoot
if($LASTEXITCODE -ne 0) {
    throw "Failed to install npm dependencies"
}

npm run build --prefix $PSScriptRoot
if($LASTEXITCODE -ne 0) {
    throw "Failed to run npm build"
}

if($NonInteractive) {
    return
}

# Deploy to preview
if(npx --yes wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
    Write-Host "Already logged into cloudflare"
} else {
    npx wrangler login
}
npx wrangler pages deploy "$PSScriptRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=test

# Yeet it to cloudflare
$choice = Read-Host "`nDeploy to Prod CF pages? (y/n)"
if($choice -eq "y") {
    if(npx wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
        Write-Host "Already logged into cloudflare"
    } else {
        npx wrangler login
    }
    npx wrangler pages deploy "$PSScriptRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=main
}