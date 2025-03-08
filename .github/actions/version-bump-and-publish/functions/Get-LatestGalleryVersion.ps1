function Get-LatestGalleryVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [ValidateSet("stable", "prerelease")]
        [string]$Type
    )

    $onlineVersions = Find-Module -Name $ModuleName -AllowPrerelease -AllVersions

    Write-Host "Found $($($onlineVersions.Count)) versions of $ModuleName in the gallery"

    $version = $null

    if ($Type -eq "stable") {
        $latestStableVersion = $onlineVersions `
            | Where-Object { $_.Version -notlike "*prerelease*" } `
            | Sort-Object { [semver]$_.Version } -Descending `
            | Select-Object -First 1 -ExpandProperty Version
        
        $version = [semver]$latestStableVersion
    } else {
        $latestPrereleaseVersion = $onlineVersions `
            | Where-Object { $_.Version -like "*prerelease*" } `
            | Sort-Object { [semver]$_.Version } -Descending `
            | Select-Object -First 1 -ExpandProperty Version

        $version = [semver]$latestPrereleaseVersion
    }

    if ($null -eq $version) {
        throw "No version found for type $Type"
    }

    Write-Host "Latest $Type version: $version"
    
    return $version
}