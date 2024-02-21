param (
    [string] $Version = "0.48.0"
)

function Install-SpectreConsole {
    param (
        [string] $InstallLocation,
        [string] $TestingInstallLocation,
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
}

Write-Host "Downloading Spectre.Console version $Version"
$installLocation = (Join-Path $PSScriptRoot "packages")
$testingInstallLocation = (Join-Path $PSScriptRoot ".." "PwshSpectreConsole.Tests" "packages")
if(Test-Path $installLocation) {
    Remove-Item $installLocation -Recurse -Force
}
if(Test-Path $testingInstallLocation) {
    Remove-Item $testingInstallLocation -Recurse -Force
}
Install-SpectreConsole -InstallLocation $installLocation -TestingInstallLocation $testingInstallLocation -Version $Version
