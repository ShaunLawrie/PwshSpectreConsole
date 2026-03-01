function Get-LocalModuleVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleManifestPath
    )

    Write-Host "Loading local module version from manifest at $ModuleManifestPath"
    $manifestContent = Get-Content -Path $ModuleManifestPath -Raw
    if ($manifestContent -match "ModuleVersion\s*=\s*'(.+?)'") {
        $localModuleVersion = $matches[1]
    } else {
        throw "Failed to load version from module manifest at $ModuleManifestPath"
    }

    if($null -eq $localModuleVersion) {
        throw "Failed to load version for local module at $ModuleManifestPath"
    }

    Write-Host "Local module version: $localModuleVersion"
    
    return [semver]$localModuleVersion
}