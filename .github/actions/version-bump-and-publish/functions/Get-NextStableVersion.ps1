function Get-NextStableVersion {
    param (
        [Parameter(Mandatory = $true)]
        [semver]$LocalModuleVersion,
        [Parameter(Mandatory = $true)]
        [semver]$LatestGalleryStableVersion,
        [Parameter(Mandatory = $true)]
        [semver]$LatestGalleryPrereleaseVersion
    )

    Write-Host "Getting next stable version..."
    Write-Host "Local module version: $LocalModuleVersion"
    Write-Host "Latest stable version: $LatestGalleryStableVersion"
    Write-Host "Latest prerelease version: $LatestGalleryPrereleaseVersion"

    $latestGalleryPrereleaseVersionWithoutPrereleaseLabel = [semver]::new($LatestGalleryPrereleaseVersion.Major, $LatestGalleryPrereleaseVersion.Minor, $LatestGalleryPrereleaseVersion.Patch)

    $nextVersion = $null

    if ($LocalModuleVersion -gt $LatestGalleryStableVersion -and $LocalModuleVersion -gt $latestGalleryPrereleaseVersionWithoutPrereleaseLabel) {
        Write-Host "Local module version is greater than both the latest stable and prerelease versions, setting version to local module version"
        $nextVersion = [semver]::new($LocalModuleVersion.Major, $LocalModuleVersion.Minor, $LocalModuleVersion.Patch)
    } elseif ($LatestGalleryStableVersion -lt $latestGalleryPrereleaseVersionWithoutPrereleaseLabel) {
        Write-Host "Latest stable version is less than the latest prerelease version, setting next stable version to the latest prerelease version"
        $nextVersion = [semver]::new($LatestGalleryPrereleaseVersion.Major, $LatestGalleryPrereleaseVersion.Minor, $LatestGalleryPrereleaseVersion.Patch)
    } else {
        Write-Host "Bumping the stable version patch number"
        $nextVersion = [semver]::new($LatestGalleryStableVersion.Major, $LatestGalleryStableVersion.Minor, $LatestGalleryStableVersion.Patch + 1)
    }

    if ($null -eq $nextVersion) {
        throw "Could not determine the new version."
    }

    Write-Host "Next stable version: $nextVersion"

    return $nextVersion
}