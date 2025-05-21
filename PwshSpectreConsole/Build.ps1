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

        # Build Json integration
        & dotnet build -c Release "src/Spectre.Console.Json/Spectre.Console.Json.csproj"
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console.Json"
        }
        
        # Create target directories
        $spectreConsolePath = Join-Path $InstallLocation "Spectre.Console\lib\net6.0"
        $spectreConsoleImageSharpPath = Join-Path $InstallLocation "Spectre.Console.ImageSharp\lib\net6.0"
        $spectreConsoleJsonPath = Join-Path $InstallLocation "Spectre.Console.Json\lib\net6.0"
        
        New-Item -Path $spectreConsolePath -ItemType Directory -Force | Out-Null
        New-Item -Path $spectreConsoleImageSharpPath -ItemType Directory -Force | Out-Null
        New-Item -Path $spectreConsoleJsonPath -ItemType Directory -Force | Out-Null
        
        # Copy built DLLs to the install location
        Copy-Item -Path "src/Spectre.Console/bin/Release/net6.0/Spectre.Console.dll" -Destination $spectreConsolePath -Force
        Copy-Item -Path "src/Spectre.Console.ImageSharp/bin/Release/net6.0/Spectre.Console.ImageSharp.dll" -Destination $spectreConsoleImageSharpPath -Force
        Copy-Item -Path "src/Spectre.Console.Json/bin/Release/net6.0/Spectre.Console.Json.dll" -Destination $spectreConsoleJsonPath -Force
        
        # Also need to copy SixLabors.ImageSharp dependency
        $sixLaborsPath = Join-Path $InstallLocation "SixLabors.ImageSharp\lib\net6.0"
        New-Item -Path $sixLaborsPath -ItemType Directory -Force | Out-Null
        
        # Find ImageSharp DLL in the build output
        $imageSharpDll = Get-ChildItem -Path "$RepoDirectory\src\Spectre.Console.ImageSharp\bin\Release\net6.0" -Filter "SixLabors.ImageSharp.dll" -Recurse | Select-Object -First 1
        if ($null -ne $imageSharpDll) {
            Copy-Item -Path $imageSharpDll.FullName -Destination $sixLaborsPath -Force
            Write-Host "Copied SixLabors.ImageSharp.dll from build output"
        } else {
            Write-Warning "Could not find SixLabors.ImageSharp.dll in build output"
        }
        
        Write-Host "Successfully built and copied Spectre.Console assemblies"
    }
    finally {
        Pop-Location
    }
}

Write-Host "Setting up Spectre.Console from fork"
$installLocation = (Join-Path $PSScriptRoot "packages")
$csharpProjectLocation = (Join-Path $PSScriptRoot "private" "classes")
$testingInstallLocation = (Join-Path $PSScriptRoot ".." "PwshSpectreConsole.Tests" "packages")
$tempSpectreConsoleRepoDir = Join-Path $PSScriptRoot ".spectre.build"

if ((Test-Path $installLocation) -and $NoReinstall) {
    Write-Host "Spectre.Console already installed, skipping"
    return
} 

if ($WhatIfPreference) {
    Write-Host "WhatIf: Would have installed the Spectre.Console from fork"
    return
}

if (Test-Path $installLocation) {
    Remove-Item $installLocation -Recurse -Force
}

if (Test-Path $testingInstallLocation) {
    Remove-Item $testingInstallLocation -Recurse -Force
}

# Create directories
New-Item -Path $installLocation -ItemType Directory -Force | Out-Null
New-Item -Path $testingInstallLocation -ItemType Directory -Force | Out-Null

# Clone and build the Spectre.Console fork
$repoPath = Clone-SpectreConsoleRepository -RepoUrl $SpectreConsoleRepoUrl -Branch $SepctreConsoleBranch -TempDirectory $tempSpectreConsoleRepoDir

# Build the forked Spectre.Console
Build-SpectreConsole -RepoDirectory $repoPath -InstallLocation $installLocation -DotnetSdkMajorVersion $DotnetSdkMajorVersion

# Create Testing directory structure (might be needed for tests)
$testingPath = Join-Path $testingInstallLocation "Spectre.Console.Testing\lib\net6.0"
New-Item -Path $testingPath -ItemType Directory -Force | Out-Null

# Try to find and copy Spectre.Console.Testing.dll from build output if it exists
$testingDll = Get-ChildItem -Path "$repoPath\src" -Filter "Spectre.Console.Testing.dll" -Recurse | Select-Object -First 1
if ($null -ne $testingDll) {
    Copy-Item -Path $testingDll.FullName -Destination $testingPath -Force
    Write-Host "Copied Spectre.Console.Testing.dll from build output"
} else {
    Write-Warning "Could not find Spectre.Console.Testing.dll in build output. This may not be an issue if tests don't require it."
}

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