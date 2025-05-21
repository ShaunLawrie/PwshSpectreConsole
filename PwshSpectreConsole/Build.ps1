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

    # Create full temp directory path
    $fullTempPath = (Resolve-Path $TempDirectory -ErrorAction SilentlyContinue).Path
    if (-not $fullTempPath) {
        $fullTempPath = Join-Path (Resolve-Path .) $TempDirectory
    }
    
    Write-Host "Cloning Spectre.Console fork from $RepoUrl ($Branch branch) into $fullTempPath"
    
    # Check if directory already exists and remove it to ensure a clean clone
    if (Test-Path $fullTempPath) {
        Write-Host "Removing existing directory at $fullTempPath"
        Remove-Item -Path $fullTempPath -Recurse -Force
    }
    
    # Create the directory
    New-Item -Path $fullTempPath -ItemType Directory -Force | Out-Null
    
    try {
        Push-Location
        Set-Location $fullTempPath
        
        # Check if git is available
        $gitCommand = Get-Command "git" -ErrorAction SilentlyContinue
        if ($null -eq $gitCommand) {
            throw "Git not found, please install git to build from the forked repository"
        }
        
        # Clone the repository 
        Write-Host "Cloning fresh repository..."
        $output = & git clone --branch $Branch $RepoUrl .
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to clone $RepoUrl. Error: $output"
        }
    } 
    finally {
        Pop-Location
    }

    # Verify the directory structure
    if (-not (Test-Path "$fullTempPath/src")) {
        throw "Invalid repository structure. src directory not found in $fullTempPath"
    }
    
    Write-Host "Repository cloned successfully to $fullTempPath"
    return $fullTempPath
}

function Build-SpectreConsole {
    param (
        [string] $RepoDirectory,
        [string] $InstallLocation,
        [int] $DotnetSdkMajorVersion
    )

    # Verify that the repo directory exists
    if (-not (Test-Path $RepoDirectory)) {
        throw "Repository directory '$RepoDirectory' does not exist"
    }
    
    # Verify project files exist
    $spectreConsoleProject = Join-Path $RepoDirectory "src/Spectre.Console/Spectre.Console.csproj"
    $spectreConsoleImageSharpProject = Join-Path $RepoDirectory "src/Extensions/Spectre.Console.ImageSharp/Spectre.Console.ImageSharp.csproj"
    $spectreConsoleJsonProject = Join-Path $RepoDirectory "src/Extensions/Spectre.Console.Json/Spectre.Console.Json.csproj"
    $spectreConsoleTestingProject = Join-Path $RepoDirectory "src/Spectre.Console.Testing/Spectre.Console.Testing.csproj"
    
    if (-not (Test-Path $spectreConsoleProject)) {
        throw "Spectre.Console project not found at $spectreConsoleProject"
    }
    
    if (-not (Test-Path $spectreConsoleImageSharpProject)) {
        throw "Spectre.Console.ImageSharp project not found at $spectreConsoleImageSharpProject"
    }
    
    if (-not (Test-Path $spectreConsoleJsonProject)) {
        throw "Spectre.Console.Json project not found at $spectreConsoleJsonProject"
    }
    
    try {
        Push-Location
        Set-Location $RepoDirectory
        
        Write-Host "Building Spectre.Console from source"
        
        # Build the solution
        & dotnet build -c Release $spectreConsoleProject
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console"
        }
        
        # Build ImageSharp integration
        & dotnet build -c Release $spectreConsoleImageSharpProject
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console.ImageSharp"
        }

        # Build Json integration
        & dotnet build -c Release $spectreConsoleJsonProject
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console.Json"
        }

        # Build Testing project if it exists
        if (Test-Path $spectreConsoleTestingProject) {
            & dotnet build -c Release $spectreConsoleTestingProject
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to build Spectre.Console.Testing, this may not be an issue if tests don't need it."
            }
        }
        
        # Create target directories
        $spectreConsolePath = Join-Path $InstallLocation "Spectre.Console\lib\net6.0"
        $spectreConsoleImageSharpPath = Join-Path $InstallLocation "Spectre.Console.ImageSharp\lib\net6.0"
        $spectreConsoleJsonPath = Join-Path $InstallLocation "Spectre.Console.Json\lib\net6.0"
        $sixLaborsPath = Join-Path $InstallLocation "SixLabors.ImageSharp\lib\net6.0"
        $spectreConsoleTestingPath = Join-Path $InstallLocation "Spectre.Console.Testing\lib\net6.0"
        
        New-Item -Path $spectreConsolePath -ItemType Directory -Force | Out-Null
        New-Item -Path $spectreConsoleImageSharpPath -ItemType Directory -Force | Out-Null
        New-Item -Path $spectreConsoleJsonPath -ItemType Directory -Force | Out-Null
        New-Item -Path $sixLaborsPath -ItemType Directory -Force | Out-Null
        New-Item -Path $spectreConsoleTestingPath -ItemType Directory -Force | Out-Null
        
        # Copy built DLLs to the install location
        Write-Host "Copying built assemblies to destination"
        $spectreConsoleDll = Get-ChildItem -Path "$RepoDirectory/src/Spectre.Console/bin/Release" -Filter "Spectre.Console.dll" -Recurse | Select-Object -First 1
        if ($null -ne $spectreConsoleDll) {
            Copy-Item -Path $spectreConsoleDll.FullName -Destination $spectreConsolePath -Force
            Write-Host "Copied Spectre.Console.dll from $($spectreConsoleDll.FullName)"
        } else {
            throw "Could not find Spectre.Console.dll in the build output"
        }
        
        $spectreConsoleImageSharpDll = Get-ChildItem -Path "$RepoDirectory/src/Extensions/Spectre.Console.ImageSharp/bin/Release" -Filter "Spectre.Console.ImageSharp.dll" -Recurse | Select-Object -First 1
        if ($null -ne $spectreConsoleImageSharpDll) {
            Copy-Item -Path $spectreConsoleImageSharpDll.FullName -Destination $spectreConsoleImageSharpPath -Force
            Write-Host "Copied Spectre.Console.ImageSharp.dll from $($spectreConsoleImageSharpDll.FullName)"
        } else {
            throw "Could not find Spectre.Console.ImageSharp.dll in the build output"
        }
        
        $spectreConsoleJsonDll = Get-ChildItem -Path "$RepoDirectory/src/Extensions/Spectre.Console.Json/bin/Release" -Filter "Spectre.Console.Json.dll" -Recurse | Select-Object -First 1
        if ($null -ne $spectreConsoleJsonDll) {
            Copy-Item -Path $spectreConsoleJsonDll.FullName -Destination $spectreConsoleJsonPath -Force
            Write-Host "Copied Spectre.Console.Json.dll from $($spectreConsoleJsonDll.FullName)"
        } else {
            throw "Could not find Spectre.Console.Json.dll in the build output"
        }
        
        # Find and copy SixLabors.ImageSharp dependency
        $imageSharpDll = Get-ChildItem -Path "$RepoDirectory/src/Extensions/Spectre.Console.ImageSharp/bin/Release" -Filter "SixLabors.ImageSharp.dll" -Recurse | Select-Object -First 1
        if ($null -ne $imageSharpDll) {
            Copy-Item -Path $imageSharpDll.FullName -Destination $sixLaborsPath -Force
            Write-Host "Copied SixLabors.ImageSharp.dll from $($imageSharpDll.FullName)"
        } else {
            Write-Warning "Could not find SixLabors.ImageSharp.dll in build output"
        }
        
        # Try to find and copy Spectre.Console.Testing.dll if it exists
        $testingDll = Get-ChildItem -Path "$RepoDirectory/src/Spectre.Console.Testing/bin/Release" -Filter "Spectre.Console.Testing.dll" -Recurse | Select-Object -First 1
        if ($null -ne $testingDll) {
            Copy-Item -Path $testingDll.FullName -Destination $spectreConsoleTestingPath -Force
            Write-Host "Copied Spectre.Console.Testing.dll from $($testingDll.FullName)"
        } else {
            Write-Warning "Could not find Spectre.Console.Testing.dll in build output. This may not be an issue if tests don't require it."
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
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build PowerShell module classes"
    }
} finally {
    Pop-Location
}

Write-Host "Spectre.Console fork has been successfully built and installed"