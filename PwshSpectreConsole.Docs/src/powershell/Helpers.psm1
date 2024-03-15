$script:Groups = @(
    @{ Name = "Prompts/"; Matches = @("read-") }
    @{ Name = "Formatting/"; Matches = @("format-", "chartitem") }
    @{ Name = "Progress/"; Matches = @("invoke-", "job", "spectrescriptblock") }
    @{ Name = "Images/"; Matches = @("image") }
    @{ Name = "Writing/"; Matches = @("write-", "escaped") }
    @{ Name = "Config/"; Matches = @("set-", "recording") }
    @{ Name = "Demo/"; Matches = @("spectredemo") }
)

<#
.SYNOPSIS
    Gets the folder group based on the provided name.

.DESCRIPTION
    The Get-Group function retrieves the group based on the provided name. It searches for a match in the script's Groups collection and returns the matching group.
    If no match is found, it returns the default group with the name "/".

.PARAMETER Name
    Specifies the name of the group to retrieve.
#>
function Get-Group {
    param (
        [string] $Name
    )
    $group = @{ Name = "/" }
    foreach ($testGroup in $script:Groups) {
        foreach ($match in $testGroup.Matches) {
            if ($Name -like "*$match*") {
                $group = $testGroup
                break
            }
        }
    }
    return $group
}

$script:NewTag = @"
sidebar:
  badge:
    text: New
    variant: tip
"@

$script:UpdatedTag = @"
sidebar:
  badge:
    text: Updated
    variant: tip
"@

$script:ExperimentalTag = @"
sidebar:
  badge:
    text: Experimental
    variant: caution
"@

<#
.SYNOPSIS
    Returns the yaml to inject for a specific tag.

.PARAMETER Tag
    Specifies the tag to retrieve the value for.
#>
function Get-Tag {
    param (
        [ValidateSet("New", "Updated", "Experimental")]
        [string] $Tag
    )
    switch ($Tag) {
        "New" { return $script:NewTag }
        "Updated" { return $script:UpdatedTag }
        "Experimental" { return $script:ExperimentalTag }
    }
}

<#
.SYNOPSIS
    Updates the hash files in a Git repository.

.DESCRIPTION
    The Update-HashFilesInGit function updates the hash files in a Git repository. It takes the staging path and the output path as parameters.
    It finds all the hash files in the staging path with the .sha256 extension and copies them to the corresponding location in the output path
    It then commits all of the files to source control.

.PARAMETER StagingPath
    The path where the hash files are located.

.PARAMETER OutputPath
    The path where the updated hash files will be copied.
#>
function Update-HashFilesInGit {
    param (
        [string] $StagingPath,
        [string] $OutputPath
    )

    Push-Location
    try {
        # Get only the hashfiles to update
        $hashFiles = Get-ChildItem $StagingPath -Filter "*.sha256" -Recurse

        foreach($hashFile in $hashFiles) {
            $group = Get-Group -Name $hashFile.Name
            $hashOutParentLocation = Join-Path $OutputPath $group.Name
            $hashOutLocation = Join-Path $hashOutParentLocation $hashFile.Name
            New-Item $hashOutParentLocation -ItemType Directory -Force | Out-Null
            Remove-Item $hashOutLocation -Force -ErrorAction SilentlyContinue
            Copy-Item -Path $hashFile.FullName -Destination $hashOutLocation -Force
        }

        # Update git hash files
        try {
            Set-Location $OutputPath
            Write-Host "Committing hash files"
            git add "*.sha256" *>$null
            git commit -m "[skip ci] Update doc hashfiles" *>$null
        } catch {
            Write-Host "No changes to commit"
        }
    } finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Updates the help files by copying them from the staging path to the output path.

.DESCRIPTION
    The Update-HelpFiles function updates the help files by copying them from the staging path to the output path.
    It searches for Markdown files (*.md) in the staging path and copies them to the corresponding location in the output path.
    The help files are then committed to source control.

.PARAMETER StagingPath
    The path where the help files are staged.

.PARAMETER OutputPath
    The path where the updated help files will be copied.
#>
function Update-HelpFiles {
    param (
        [string] $StagingPath,
        [string] $OutputPath,
        [string] $AsciiCastOutputPath
    )

    Push-Location
    try {
        # Get only the helpFiles to update
        $helpFiles = Get-ChildItem $StagingPath -Filter "*.md" -Recurse | Where-Object { $_.Name -like "*-*" }

        foreach($helpFile in $helpFiles) {
            $group = Get-Group -Name $helpFile.Name
            $helpOutParentLocation = Join-Path $OutputPath $group.Name
            $helpOutLocation = Join-Path $helpOutParentLocation ($helpFile.Name -replace '.md$', '.mdx')
            New-Item $helpOutParentLocation -ItemType Directory -Force | Out-Null
            Remove-Item $helpOutLocation -Force -ErrorAction SilentlyContinue
            Copy-Item -Path $helpFile.FullName -Destination $helpOutLocation -Force
        }

        try {
            Set-Location $OutputPath
            Write-Host "Committing mdx files"
            git add "*.mdx" *>$null
            Set-Location $AsciiCastOutputPath
            Write-Host "Committing cast files"
            git add "*.cast" *>$null
            git commit -m "[skip ci] Update docs" *>$null
        } catch {
            Write-Host "No changes to commit"
        }
    } finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Retrieves the commit dates for a specified hash file in a Git repository.

.DESCRIPTION
    The Get-GitCommitDatesForHashFile function retrieves the commit dates for a hash file related to a specified help file.
    It uses the Git command line tool to retrieve the commit dates.

.PARAMETER Name
    The name of the help file to find the hash file for.

.PARAMETER OutputPath
    The output path where the help docs and hash file is located.
#>
function Get-GitCommitDatesForHashFile {
    param (
        [string] $Name,
        [string] $OutputPath
    )

    Push-Location
    try {
        Set-Location $OutputPath
        $group = Get-Group -Name $Name
        $hashfileName = "_" + ($doc.Name -replace '.md$', '.sha256')
        $gitHashfileName = Join-Path $group.Name $hashfileName
        $dates = git log --follow --pretty="format:%ci" -- $gitHashfileName
        return $dates
    } finally {
        Pop-Location
    }
}

$script:AsciiCastTemplate = @'
<Asciinema
    src="CAST_URL"
    settings={{
        loop: false,
        poster: 'npt:0:0.5',
        terminalLineHeight: 1.1,
        theme: "spectre"
    }}
/>
'@

function Get-AsciiCastTemplate {
    param (
        [string] $Name
    )

    return $script:AsciiCastTemplate -replace "CAST_URL", $Name
}