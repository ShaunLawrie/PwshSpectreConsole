function Get-NextVersion {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet("stable", "prerelease")]
        [string]$Type
    )

    $latestGalleryStableVersion = Get-LatestGalleryVersion -Type "stable" -ModuleName "PwshSpectreConsole"
    $latestGalleryPrereleaseVersion = Get-LatestGalleryVersion -Type "prerelease" -ModuleName "PwshSpectreConsole"
    $localModuleVersion = Get-LocalModuleVersion -ModuleName "PwshSpectreConsole"

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