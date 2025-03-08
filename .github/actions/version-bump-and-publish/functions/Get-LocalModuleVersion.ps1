function Get-LocalModuleVersion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    Write-Host "Loading local module version for $ModuleName"
    $localModuleVersion = Get-Module $ModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1 -ExpandProperty Version
    
    if($null -eq $localModuleVersion) {
        throw "Failed to load version for local module $ModuleName"
    }

    Write-Host "Local module version: $localModuleVersion"
    
    return [semver]$localModuleVersion
}