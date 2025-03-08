function Get-NextPrereleaseVersion {
    param (
        [Parameter(Mandatory = $true)]
        [semver]$LocalModuleVersion,
        [Parameter(Mandatory = $true)]
        [semver]$LatestGalleryStableVersion,
        [Parameter(Mandatory = $true)]
        [semver]$LatestGalleryPrereleaseVersion
    )

    Write-Host "Getting next prerelease version..."
    Write-Host "Local module version: $LocalModuleVersion"
    Write-Host "Latest stable version: $LatestGalleryStableVersion"
    Write-Host "Latest prerelease version: $LatestGalleryPrereleaseVersion"

    $latestGalleryPrereleaseVersionWithoutPrereleaseLabel = [semver]::new($LatestGalleryPrereleaseVersion.Major, $LatestGalleryPrereleaseVersion.Minor, $LatestGalleryPrereleaseVersion.Patch)

    $nextVersion = $null

    if ($LocalModuleVersion -gt $LatestGalleryStableVersion -and $LocalModuleVersion -gt $latestGalleryPrereleaseVersionWithoutPrereleaseLabel) {
        Write-Host "Local module version is greater than both the latest stable and prerelease versions, resetting prerelease tag to 001 and setting version to local module version"
        $nextVersion = [semver]::new($LocalModuleVersion.Major, $LocalModuleVersion.Minor, $LocalModuleVersion.Patch, "prerelease001")
    } elseif ($LatestGalleryStableVersion -gt $LatestGalleryPrereleaseVersion) {
        Write-Host "Latest stable version is greater than the latest prerelease version, resetting prerelease tag to 001 and bumping the prerelease minor version 1 ahead of stable"
        $nextVersion = [semver]::new($LatestGalleryStableVersion.Major, $LatestGalleryStableVersion.Minor + 1, 0, "prerelease001")
    } else {
        Write-Host "Bumping the prerelease label"
        $latestPrereleaseNumber = [int]($LatestGalleryPrereleaseVersion.PreReleaseLabel -replace "prerelease", "")
        $nextPrereleaseTag = "prerelease" + ($latestPrereleaseNumber + 1).ToString("000")
        $nextVersion = [semver]::new($LatestGalleryPrereleaseVersion.Major, $LatestGalleryPrereleaseVersion.Minor, $LatestGalleryPrereleaseVersion.Patch, $nextPrereleaseTag)
    }

    if ($null -eq $nextVersion) {
        throw "Could not determine the next prerelease version."
    }

    Write-Host "Next prerelease version: $($nextVersion)"

    return $nextVersion
}