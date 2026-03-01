function Get-NextVersion {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("stable", "prerelease")]
        [string]$Type,
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$ModuleManifestPath
    )

    $latestGalleryStableVersion = Get-LatestGalleryVersion -Type "stable" -ModuleName $ModuleName
    $latestGalleryPrereleaseVersion = Get-LatestGalleryVersion -Type "prerelease" -ModuleName $ModuleName
    $localModuleVersion = Get-LocalModuleVersion -ModuleManifestPath $ModuleManifestPath

    if ($Type -eq "stable") {
        return Get-NextStableVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    } else {
        return Get-NextPrereleaseVersion `
            -LocalModuleVersion $localModuleVersion `
            -LatestGalleryStableVersion $latestGalleryStableVersion `
            -LatestGalleryPrereleaseVersion $latestGalleryPrereleaseVersion
    }
}