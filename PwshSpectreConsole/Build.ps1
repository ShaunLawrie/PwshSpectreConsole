param (
    [string] $Version = "0.49.1",
    [int] $DotnetSdkMajorVersion = 8
)

function Install-SpectreConsole {
    param (
        [string] $InstallLocation,
        [string] $TestingInstallLocation,
        [string] $CsharpProjectLocation,
        [string] $Version
    )

    New-Item -Path $InstallLocation -ItemType "Directory" -Force | Out-Null

    $libPath = Join-Path $TestingInstallLocation "Spectre.Console.Testing"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Spectre.Console.Testing/$Version" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

    $libPath = Join-Path $InstallLocation "Spectre.Console"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Spectre.Console/$Version" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

    $libPath = Join-Path $InstallLocation "Spectre.Console.ImageSharp"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Spectre.Console.ImageSharp/$Version" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

    Write-Verbose "Finding imagesharp dependency"
    $nuspec = [xml](Get-Content (Join-Path $libPath "Spectre.Console.ImageSharp.nuspec"))
    $imageSharpVersion = (($nuspec.package.metadata.dependencies.group | Where-Object { $_.targetFramework -eq ".NETStandard2.0" }).dependency | Where-Object { $_.id -eq "SixLabors.ImageSharp" }).version

    $libPath = Join-Path $InstallLocation "SixLabors.ImageSharp"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/SixLabors.ImageSharp/$imageSharpVersion" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

    $libPath = Join-Path $InstallLocation "Spectre.Console.Json"
    New-Item -Path $libPath -ItemType "Directory" -Force | Out-Null
    $downloadLocation = Join-Path $libPath "download.zip"
    Invoke-WebRequest "https://www.nuget.org/api/v2/package/Spectre.Console.Json/$Version" -OutFile $downloadLocation -UseBasicParsing
    Expand-Archive $downloadLocation $libPath -Force
    Remove-Item $downloadLocation

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
        & dotnet build -c Release -o $installLocation
    } finally {
        Pop-Location
    }
}

Write-Host "Downloading Spectre.Console version $Version"
$installLocation = (Join-Path $PSScriptRoot "packages")
$csharpProjectLocation = (Join-Path $PSScriptRoot "private" "classes")
$testingInstallLocation = (Join-Path $PSScriptRoot ".." "PwshSpectreConsole.Tests" "packages")
if (Test-Path $installLocation) {
    Remove-Item $installLocation -Recurse -Force
}
if (Test-Path $testingInstallLocation) {
    Remove-Item $testingInstallLocation -Recurse -Force
}
Install-SpectreConsole -InstallLocation $installLocation -TestingInstallLocation $testingInstallLocation -CsharpProjectLocation $csharpProjectLocation -Version $Version