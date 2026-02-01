[CmdletBinding(SupportsShouldProcess = $true)]
param (
    # [string] $Version = "0.54.0",
    [int] $DotnetSdkMajorVersion = 8,
    [switch] $NoReinstall
)

function Install-SpectreConsole {
    param(
        [string] $InstallLocation,
        [string] $CsharpProjectLocation
    )

    $command = Get-Command "dotnet" -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "dotnet not found, please install dotnet sdk $DotnetSdkMajorVersion"
    } elseif (-not (dotnet --list-sdks | Select-String "^$DotnetSdkMajorVersion.+")) {
        Write-Warning "dotnet sdk $DotnetSdkMajorVersion not found, please install dotnet sdk $DotnetSdkMajorVersion"
        if (Get-Command "winget" -ErrorAction SilentlyContinue) {
            winget install "Microsoft.DotNet.SDK.$DotnetSdkMajorVersion"
        } else {
            throw "Please install the dotnet sdk and try again"
        }
    }
    try {
        Push-Location
        Set-Location -Path $CsharpProjectLocation
        & dotnet publish -c Release -o $installLocation
    } finally {
        Pop-Location
    }
}

Write-Host "Downloading Spectre.Console"
$installLocation = Join-Path $PSScriptRoot 'lib'
$csharpProjectLocation = Resolve-Path (Join-Path $PSScriptRoot ".." "PwshSpectreConsole.Src")

if ((Test-Path $installLocation) -and $NoReinstall) {
    Write-Host "Spectre.Console already installed, skipping"
    return
}

if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have installed the Spectre.Console packages"
    return
}

if (Test-Path $installLocation) {
    Remove-Item $installLocation -Recurse -Force
}

Install-SpectreConsole -InstallLocation $installLocation -CsharpProjectLocation $csharpProjectLocation
