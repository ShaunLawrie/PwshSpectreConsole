#requires -Modules HelpOut

$ErrorActionPreference = "Stop"

Import-Module "..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Remove-Item -Recurse -Path ".\src\content\docs\reference\*" -Force
Get-Module PwshSpectreConsole | Save-MarkdownHelp -OutputPath ".\src\content\docs\reference\" -IncludeYamlHeader -YamlHeaderInformationType Metadata -ExcludeFile "*.gif", "*.png"

# Post-processing for astro stuff
$groups = @(
    @{ Name = "Prompts"; Matches = @("read-") }
    @{ Name = "Formatting"; Matches = @("format-") }
    @{ Name = "Progress"; Matches = @("invoke-", "job") }
    @{ Name = "Images"; Matches = @("image") }
    @{ Name = "Writing"; Matches = @("write-", "escaped") }
    @{ Name = "Config"; Matches = @("set-") }
)
$remove = @("Start-SpectreDemo.md")
$docs = Get-ChildItem ".\src\content\docs\reference\" -Filter "*.md" -Recurse
foreach($doc in $docs) {
    if($remove -contains $doc.Name) {
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

    $outLocation = ".\src\content\docs\reference\$($group.Name)\$($doc.Name)"
    if($null -eq $group) {
        $outLocation = $doc.FullName
    }
    New-Item -ItemType Directory -Path ".\src\content\docs\reference\$($group.Name)" -Force | Out-Null
    $content = Get-Content $doc.FullName -Raw
    Remove-Item $doc.FullName
    $content -replace '```PowerShell', '```powershell' -replace '(?m)^.+\n^[\-]{10,99}', '' | Out-File $outLocation
}

# Build the docs site
npm run build --prefix .\

# Yeet it to cloudflare
$choice = Read-Host "`nDeploy to CF pages? (y/n)"
if($choice -eq "y") {
    if(npx wrangler whoami | Where-Object { $_ -like "*You are logged in*" }) {
        Write-Host "Already logged into cloudflare"
    } else {
        npx wrangler login
    }
    npx wrangler pages deploy .\dist --project-name pwshspectreconsole --commit-dirty=true --branch=main
}