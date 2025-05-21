[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string] $Version = "0.49.1",
    [int] $DotnetSdkMajorVersion = 8,
    [switch] $NoReinstall,
    [string] $SpectreConsoleRepoUrl = "https://github.com/ShaunLawrie/spectre.console.git",
    [string] $SepctreConsoleBranch = "main"
)

function Clone-SpectreConsoleRepository {
    param (
        [string] $RepoUrl,
        [string] $Branch,
        [string] $TempDirectory
    )

    if (-not (Test-Path $TempDirectory)) {
        New-Item -Path $TempDirectory -ItemType Directory -Force | Out-Null
    }

    Write-Host "Cloning Spectre.Console fork from $RepoUrl ($Branch branch)"
    
    try {
        Push-Location
        Set-Location $TempDirectory
        
        # Check if git is available
        $gitCommand = Get-Command "git" -ErrorAction SilentlyContinue
        if ($null -eq $gitCommand) {
            throw "Git not found, please install git to build from the forked repository"
        }
        
        # Clone the repository if it doesn't exist, otherwise pull latest changes
        if (-not (Test-Path ".git")) {
            & git clone --branch $Branch $RepoUrl .
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to clone $RepoUrl"
            }
        } else {
            & git fetch
            & git checkout $Branch
            & git pull
            if ($LASTEXITCODE -ne 0) {
                throw "Failed to pull latest changes from $RepoUrl"
            }
        }
    } 
    finally {
        Pop-Location
    }

    return $TempDirectory
}

function Build-SpectreConsole {
    param (
        [string] $RepoDirectory,
        [string] $InstallLocation,
        [int] $DotnetSdkMajorVersion
    )

    try {
        Push-Location
        Set-Location $RepoDirectory
        
        Write-Host "Building Spectre.Console from source"
        
        # Build the solution
        & dotnet build -c Release "src/Spectre.Console/Spectre.Console.csproj"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console"
        }
        
        # Build ImageSharp integration
        & dotnet build -c Release "src/Spectre.Console.ImageSharp/Spectre.Console.ImageSharp.csproj"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console.ImageSharp"
        }
        
        # Copy built DLLs to the install location
        $spectreConsolePath = Join-Path $InstallLocation "Spectre.Console\lib\net6.0"
        if (-not (Test-Path $spectreConsolePath)) {
            New-Item -Path $spectreConsolePath -ItemType Directory -Force | Out-Null
        }
        
        $spectreConsoleImageSharpPath = Join-Path $InstallLocation "Spectre.Console.ImageSharp\lib\net6.0"
        if (-not (Test-Path $spectreConsoleImageSharpPath)) {
            New-Item -Path $spectreConsoleImageSharpPath -ItemType Directory -Force | Out-Null
        }
        
        Copy-Item -Path "src/Spectre.Console/bin/Release/net6.0/Spectre.Console.dll" -Destination $spectreConsolePath -Force
        Copy-Item -Path "src/Spectre.Console.ImageSharp/bin/Release/net6.0/Spectre.Console.ImageSharp.dll" -Destination $spectreConsoleImageSharpPath -Force
        
        Write-Host "Successfully built and copied Spectre.Console assemblies"
    }
    finally {
        Pop-Location
    }
}

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
    $imageSharpVersion = (($nuspec.package.metadata.dependencies.group | Where-Object { $_.targetFramework -eq "net$DotnetSdkMajorVersion.0" }).dependency | Where-Object { $_.id -eq "SixLabors.ImageSharp" }).version

    if ($null -eq $imageSharpVersion) {
        throw "Could not find SixLabors.ImageSharp dependency in Spectre.Console.ImageSharp.nuspec"
    }

    # https://github.com/advisories/GHSA-2cmq-823j-5qj8/
    $imageSharpVersionSemver = [semver]$imageSharpVersion
    $patchedVersion = [semver]"3.1.7"
    if ($imageSharpVersionSemver -lt $patchedVersion) {
        Write-Warning "ImageSharp version $imageSharpVersion is vulnerable to CVE-2023-45147, updating to $patchedVersion"
        $imageSharpVersion = $patchedVersion.ToString()
    }

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
$tempSpectreConsoleRepoDir = Join-Path $PSScriptRoot ".spectre.build"

if ((Test-Path $installLocation) -or (Test-Path $testingInstallLocation) -and $NoReinstall) {
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
if (Test-Path $testingInstallLocation) {
    Remove-Item $testingInstallLocation -Recurse -Force
}

# Clone and build the Spectre.Console fork
$repoPath = Clone-SpectreConsoleRepository -RepoUrl $SpectreConsoleRepoUrl -Branch $SepctreConsoleBranch -TempDirectory $tempSpectreConsoleRepoDir

# First install standard NuGet packages for Testing and Json which aren't modified in the fork
Install-SpectreConsole -InstallLocation $installLocation -TestingInstallLocation $testingInstallLocation -CsharpProjectLocation $csharpProjectLocation -Version $Version

# Now build the forked Spectre.Console and replace the NuGet packages
Build-SpectreConsole -RepoDirectory $repoPath -InstallLocation $installLocation -DotnetSdkMajorVersion $DotnetSdkMajorVersion

# Build the C# classes for the PowerShell module
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

Write-Host "Spectre.Console fork has been successfully built and installed"