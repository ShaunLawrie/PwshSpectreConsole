param (
    [string] $Version
)

function Install-SpectreConsole {
    param (
        [string] $InstallLocation,
        [string] $Version
    )
    if(Test-Path $InstallLocation) {
        Write-Verbose "Spectre.Console has already been downloaded"
    } else {
        New-Item -Path $InstallLocation -ItemType "Directory" | Out-Null
        $downloadLocation = Join-Path $InstallLocation "spectre.zip"
        Invoke-WebRequest "https://www.nuget.org/api/v2/package/Spectre.Console/$Version" -OutFile $downloadLocation -UseBasicParsing
        Expand-Archive $downloadLocation $InstallLocation
        Remove-Item $downloadLocation
    }
}

Write-Host "Downloading Spectre.Console version $Version"
Install-SpectreConsole -InstallLocation (Join-Path $PSScriptRoot "packages") -Version $Version