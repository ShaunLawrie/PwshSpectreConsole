#requires -Modules HelpOut
param(
    [switch]$NonInteractive,
    [ValidateSet("main", "prerelease")]
    [string]$Branch = "prerelease"
)

$ErrorActionPreference = "Stop"

Remove-Module -Name PwshSpectreConsole -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Remove-Item -Recurse -Path "$PSScriptRoot\src\content\docs\reference\*" -Force -ErrorAction SilentlyContinue
$module = Get-Module PwshSpectreConsole

# Stage files in a temp directory to avoid issues with astro running in dev mode locking files
$outputPath = "$PSScriptRoot\src\content\docs\reference\"
$stagingPath = "$env:TEMP\refs-staging"
if(Test-Path $stagingPath) {
    Remove-Item $stagingPath -Force -Recurse
}

if ($null -eq $module) {
    throw "Failed to import PwshSpectreConsole module"
}

$module | Save-MarkdownHelp -OutputPath $stagingPath -IncludeYamlHeader -YamlHeaderInformationType Metadata -ExcludeFile "*.gif", "*.png"

$experimental = @("Get-SpectreImageExperimental.md", "Invoke-SpectreScriptBlockQuietly.md")

$newTag = @"
sidebar:
  badge:
    text: New
    variant: tip
"@

$updatedTag = @"
sidebar:
  badge:
    text: Updated
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
    @{ Name = "Prompts/"; Matches = @("read-") }
    @{ Name = "Formatting/"; Matches = @("format-", "chartitem") }
    @{ Name = "Progress/"; Matches = @("invoke-", "job", "spectrescriptblock") }
    @{ Name = "Images/"; Matches = @("image") }
    @{ Name = "Writing/"; Matches = @("write-", "escaped") }
    @{ Name = "Config/"; Matches = @("set-") }
    @{ Name = "Demo/"; Matches = @("spectredemo") }
)

# First pass to format markdown for astro
$docs = Get-ChildItem $stagingPath -Filter "*.md" -Recurse
foreach ($doc in $docs) {
    if ($remove -contains $doc.Name -or $doc.Name -notlike "*-*") {
        Remove-Item $doc.FullName
        continue
    }

    $group = @{ Name = "/" }
    foreach ($testGroup in $groups) {
        foreach ($match in $testGroup.Matches) {
            if ($doc.Name -like "*$match*") {
                $group = $testGroup
                break
            }
        }
    }

    $outLocation = "$stagingPath\$($group.Name)$($doc.Name)"
    $hashOutLocation = "$stagingPath\$($group.Name)_$($doc.Name -replace '.md$', '-metadata.txt')"
    New-Item -ItemType Directory -Path "$stagingPath\$($group.Name)" -Force | Out-Null
    $content = Get-Content $doc.FullName -Raw
    $content = $content -replace "`r", ""
    Set-Content -Value $content -Path $doc.FullName -NoNewline

    # Handle content changes, we hash the pre-processed content so we can add a "new" badge when the content is updated
    # The file has already had carriage returns and trailing newlines removed if it was generated on windows
    $contentHash = Get-FileHash $doc.FullName -Algorithm SHA256
    Set-Content -Path $hashOutLocation -Value $contentHash.Hash.Trim() -NoNewline

    Remove-Item $doc.FullName

    $commandName = $doc.Name -replace ".md",""
    $content = $content -replace '```PowerShell', '```powershell'
    $content = $content -replace "(?m)^.+\n^[\-]{$($commandName.Length)}", ''

    if ($experimental -contains $doc.Name) {
        $content = $content -replace '(?s)^---', "---`n$experimentalTag"
    }

    $content | Out-File $outLocation -NoNewline
}

# This avoids issues with file locking when running the astro dev server locally and trying to update the help docs
if(Test-Path $outputPath) {
    Remove-Item $outputPath -Force -Recurse
}
# Moving items doesn't trigger the astro filewatcher so this copies then removes the temp version
Copy-Item -Path $stagingPath -Destination $outputPath -Force -Recurse

# Update git hash files
git config --global user.name 'Shaun Lawrie (via GitHub Actions)'
git config --global user.email 'shaun.r.lawrie@gmail.com'
try {
    git add PwshSpectreConsole.Docs/src/content 2>$null
    git commit -m "[skip ci] Update docs" 2>$null
} catch {
    Write-Host "No changes to commit"
}

# Second pass to add new tag
Push-Location
try {
    Set-Location $PSScriptRoot
    $formattedDocs = Get-ChildItem $stagingPath -Filter "*.md" -Recurse
    foreach ($doc in $formattedDocs) {
        $content = Get-Content $doc.FullName -Raw

        if ($experimental -contains $doc.Name) {
            continue
        }

        $group = @{ Name = "/" }
        foreach ($testGroup in $groups) {
            foreach ($match in $testGroup.Matches) {
                if ($doc.Name -like "*$match*") {
                    $group = $testGroup
                    break
                }
            }
        }
        
        # Get last modified date of file from git (the path is relative to this file)
        $hashfileName = "_$($doc.Name -replace '.md$', '-metadata.txt')"
        $gitHashfileName = "src/content/docs/reference/$($group.Name)$hashfileName"
        Write-Host "Checking '$gitHashfileName'"
        $dates = git log --follow --pretty="format:%ci" -- $gitHashfileName
        $modified = $dates | Select-Object -First 1
        $created = $dates | Select-Object -Last 1
        Write-Host "Dates for '$gitHashfileName' is created '$created', modified '$modified'"
        if([string]::IsNullOrEmpty($created) -or ((Get-Date) - ([datetime]$created)).TotalDays -lt 30) {
            Write-Host "Adding new badge to '$gitHashfileName' as it was modified less than 30 days ago"
            $content = $content -replace '(?s)^---', "---`n$newTag"
            Set-Content -Path $doc.FullName -Value ($content.Trim() -replace "`r", '') -NoNewline
        } elseif (-not [string]::IsNullOrEmpty($modified) -and ((Get-Date) - ([datetime]$modified)).TotalDays -lt 30) {
            Write-Host "Adding updated badge to '$gitHashfileName' as it was modified less than 30 days ago"
            $content = $content -replace '(?s)^---', "---`n$updatedTag"
            Set-Content -Path $doc.FullName -Value ($content.Trim() -replace "`r", '') -NoNewline
        }
        $content | Out-File $doc.FullName -NoNewline
    }
} finally {
    Pop-Location
}

# This avoids issues with file locking when running the astro dev server locally and trying to update the help docs
if(Test-Path $outputPath) {
    Remove-Item $outputPath -Force -Recurse
}
# Moving items doesn't trigger the astro filewatcher so this copies then removes the temp version
Copy-Item -Path $stagingPath -Destination $outputPath -Force -Recurse

# Move the new meta files
Remove-Item $stagingPath -Force -Recurse
New-Item -Path $stagingPath -ItemType Directory -Force | Out-Null

# Build the docs site
npm ci --prefix $PSScriptRoot
if ($LASTEXITCODE -ne 0) {
    throw "Failed to install npm dependencies"
}

npm run build --prefix $PSScriptRoot
if ($LASTEXITCODE -ne 0) {
    throw "Failed to run npm build"
}

if ($NonInteractive) {
    return
}

if($Branch -eq "prerelease") {
    # Deploy to preview
    if (npx --yes wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
        Write-Host "Already logged into cloudflare"
    } else {
        npx wrangler login
    }
    npx wrangler pages deploy "$PSScriptRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=prerelease
} else {
    # Yeet it to cloudflare
    $choice = Read-Host "`nDeploy to Prod CF pages? (y/n)"
    if ($choice -eq "y") {
        if (npx wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
            Write-Host "Already logged into cloudflare"
        } else {
            npx wrangler login
        }
        npx wrangler pages deploy "$PSScriptRoot\dist" --project-name pwshspectreconsole --commit-dirty=true --branch=main
    }
}