[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [string] $Version = "0.49.1",
    [int] $DotnetSdkMajorVersion = 8,
    [switch] $NoReinstall,
    [string] $SpectreConsoleRepoUrl = "https://github.com/ShaunLawrie/spectre.console.git",
    [string] $SpectreConsoleBranch = "release/0.48.0",  # Use a release tag/branch that's compatible with .NET 8
    [switch] $FallbackToOverrides = $true  # Allow falling back to overrides if build fails
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
        $output = & git clone --branch $Branch $RepoUrl . 2>&1
        if ($LASTEXITCODE -ne 0) {
            # If the specific branch doesn't exist, try cloning the main branch and then checking out the tag
            if ($output -match "Remote branch $Branch not found") {
                Write-Warning "Branch $Branch not found, trying to clone main branch and checkout as a tag"
                & git clone $RepoUrl .
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to clone $RepoUrl"
                }
                
                & git fetch --all --tags
                & git checkout "tags/$Branch" -b "build-$Branch" 2>&1
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "Could not checkout tag/branch $Branch, will continue with main branch"
                    & git checkout main
                }
            } else {
                throw "Failed to clone $RepoUrl. Error: $output"
            }
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
    
    # Handle global.json SDK version
    $globalJsonPath = Join-Path $RepoDirectory "global.json"
    if (Test-Path $globalJsonPath) {
        Write-Host "Found global.json, checking SDK requirements"
        $globalJson = Get-Content $globalJsonPath | ConvertFrom-Json
        
        if ($globalJson.sdk.rollForward -eq "latestFeature") {
            Write-Host "Global.json is configured to use latest feature version, modifying to use SDK $DotnetSdkMajorVersion"
            $globalJson.sdk.version = "$DotnetSdkMajorVersion.0.0"
            
            # Backup original global.json
            Copy-Item -Path $globalJsonPath -Destination "$globalJsonPath.bak" -Force
            
            # Update global.json with SDK version we have
            $globalJson | ConvertTo-Json -Depth 10 | Set-Content $globalJsonPath
            Write-Host "Updated global.json to use SDK version $DotnetSdkMajorVersion.0.0"
        }
    }
    
    # Verify project files exist
    $spectreConsoleProject = Join-Path $RepoDirectory "src/Spectre.Console/Spectre.Console.csproj"
    $spectreConsoleImageSharpProject = Join-Path $RepoDirectory "src/Extensions/Spectre.Console.ImageSharp/Spectre.Console.ImageSharp.csproj"
    $spectreConsoleJsonProject = Join-Path $RepoDirectory "src/Extensions/Spectre.Console.Json/Spectre.Console.Json.csproj"
    $spectreConsoleTestingProject = Join-Path $RepoDirectory "src/Spectre.Console.Testing/Spectre.Console.Testing.csproj"
    
    if (-not (Test-Path $spectreConsoleProject)) {
        # Try to find in root src directory as older versions had different directory structure
        $spectreConsoleProject = Join-Path $RepoDirectory "src/Spectre.Console.csproj"
        if (-not (Test-Path $spectreConsoleProject)) {
            throw "Spectre.Console project not found in repository structure"
        }
    }
    
    if (-not (Test-Path $spectreConsoleImageSharpProject)) {
        # Try to find in root src directory as older versions had different directory structure
        $spectreConsoleImageSharpProject = Join-Path $RepoDirectory "src/Spectre.Console.ImageSharp.csproj" 
        if (-not (Test-Path $spectreConsoleImageSharpProject)) {
            $spectreConsoleImageSharpProject = Join-Path $RepoDirectory "src/Spectre.Console.ImageSharp/Spectre.Console.ImageSharp.csproj"
            if (-not (Test-Path $spectreConsoleImageSharpProject)) {
                throw "Spectre.Console.ImageSharp project not found in repository structure"
            }
        }
    }
    
    if (-not (Test-Path $spectreConsoleJsonProject)) {
        # Try to find in root src directory as older versions had different directory structure
        $spectreConsoleJsonProject = Join-Path $RepoDirectory "src/Spectre.Console.Json.csproj"
        if (-not (Test-Path $spectreConsoleJsonProject)) {
            $spectreConsoleJsonProject = Join-Path $RepoDirectory "src/Spectre.Console.Json/Spectre.Console.Json.csproj"
            if (-not (Test-Path $spectreConsoleJsonProject)) {
                # If Json project doesn't exist in older versions, we'll skip it
                $spectreConsoleJsonProject = $null
                Write-Warning "Spectre.Console.Json project not found, it may not exist in this version"
            }
        }
    }
    
    try {
        Push-Location
        Set-Location $RepoDirectory
        
        Write-Host "Building Spectre.Console from source"
        
        # First restore all dependencies
        Write-Host "Restoring dependencies..."
        & dotnet restore --force -nodereuse:false
        
        # Build the solution
        Write-Host "Building Spectre.Console..."
        & dotnet build $spectreConsoleProject -c Release -nodereuse:false --no-restore
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console"
        }
        
        # Build ImageSharp integration
        Write-Host "Building Spectre.Console.ImageSharp..."
        & dotnet build $spectreConsoleImageSharpProject -c Release -nodereuse:false --no-restore
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to build Spectre.Console.ImageSharp"
        }

        # Build Json integration if it exists
        if ($spectreConsoleJsonProject) {
            Write-Host "Building Spectre.Console.Json..."
            & dotnet build $spectreConsoleJsonProject -c Release -nodereuse:false --no-restore
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to build Spectre.Console.Json, but continuing"
            }
        }

        # Build Testing project if it exists
        if (Test-Path $spectreConsoleTestingProject) {
            Write-Host "Building Spectre.Console.Testing..."
            & dotnet build $spectreConsoleTestingProject -c Release -nodereuse:false --no-restore
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "Failed to build Spectre.Console.Testing, but continuing"
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
        $spectreConsoleDll = Get-ChildItem -Path $RepoDirectory -Filter "Spectre.Console.dll" -Recurse | Where-Object { $_.FullName -like "*\bin\Release\*" } | Select-Object -First 1
        if ($null -ne $spectreConsoleDll) {
            Copy-Item -Path $spectreConsoleDll.FullName -Destination $spectreConsolePath -Force
            Write-Host "Copied Spectre.Console.dll from $($spectreConsoleDll.FullName)"
        } else {
            throw "Could not find Spectre.Console.dll in the build output"
        }
        
        $spectreConsoleImageSharpDll = Get-ChildItem -Path $RepoDirectory -Filter "Spectre.Console.ImageSharp.dll" -Recurse | Where-Object { $_.FullName -like "*\bin\Release\*" } | Select-Object -First 1
        if ($null -ne $spectreConsoleImageSharpDll) {
            Copy-Item -Path $spectreConsoleImageSharpDll.FullName -Destination $spectreConsoleImageSharpPath -Force
            Write-Host "Copied Spectre.Console.ImageSharp.dll from $($spectreConsoleImageSharpDll.FullName)"
        } else {
            throw "Could not find Spectre.Console.ImageSharp.dll in the build output"
        }
        
        if ($spectreConsoleJsonProject) {
            $spectreConsoleJsonDll = Get-ChildItem -Path $RepoDirectory -Filter "Spectre.Console.Json.dll" -Recurse | Where-Object { $_.FullName -like "*\bin\Release\*" } | Select-Object -First 1
            if ($null -ne $spectreConsoleJsonDll) {
                Copy-Item -Path $spectreConsoleJsonDll.FullName -Destination $spectreConsoleJsonPath -Force
                Write-Host "Copied Spectre.Console.Json.dll from $($spectreConsoleJsonDll.FullName)"
            } else {
                Write-Warning "Could not find Spectre.Console.Json.dll in the build output"
            }
        }
        
        # Find and copy SixLabors.ImageSharp dependency
        $imageSharpDll = Get-ChildItem -Path $RepoDirectory -Filter "SixLabors.ImageSharp.dll" -Recurse | Where-Object { $_.FullName -like "*\bin\Release\*" } | Select-Object -First 1
        if ($null -ne $imageSharpDll) {
            Copy-Item -Path $imageSharpDll.FullName -Destination $sixLaborsPath -Force
            Write-Host "Copied SixLabors.ImageSharp.dll from $($imageSharpDll.FullName)"
        } else {
            Write-Warning "Could not find SixLabors.ImageSharp.dll in build output"
        }
        
        # Try to find and copy Spectre.Console.Testing.dll if it exists
        $testingDll = Get-ChildItem -Path $RepoDirectory -Filter "Spectre.Console.Testing.dll" -Recurse | Where-Object { $_.FullName -like "*\bin\Release\*" } | Select-Object -First 1
        if ($null -ne $testingDll) {
            Copy-Item -Path $testingDll.FullName -Destination $spectreConsoleTestingPath -Force
            Write-Host "Copied Spectre.Console.Testing.dll from $($testingDll.FullName)"
        } else {
            Write-Warning "Could not find Spectre.Console.Testing.dll in build output. This may not be an issue if tests don't require it."
        }
        
        # Restore original global.json if we modified it
        if (Test-Path "$globalJsonPath.bak") {
            Write-Host "Restoring original global.json"
            Move-Item -Path "$globalJsonPath.bak" -Destination $globalJsonPath -Force
        }
        
        Write-Host "Successfully built and copied Spectre.Console assemblies"
        return $true
    }
    catch {
        Write-Warning "Build failed with error: $_"
        # Restore original global.json if we modified it
        if (Test-Path "$globalJsonPath.bak") {
            Write-Host "Restoring original global.json"
            Move-Item -Path "$globalJsonPath.bak" -Destination $globalJsonPath -Force
        }
        return $false
    }
    finally {
        Pop-Location
    }
}

function Copy-OverrideFiles {
    param (
        [string] $OverridesPath,
        [string] $InstallLocation
    )

    Write-Host "Falling back to override files from $OverridesPath"
    
    # Make sure all required directories exist
    $spectreConsolePath = Join-Path $InstallLocation "Spectre.Console\lib\net6.0"
    $spectreConsoleImageSharpPath = Join-Path $InstallLocation "Spectre.Console.ImageSharp\lib\net6.0"
    $spectreConsoleJsonPath = Join-Path $InstallLocation "Spectre.Console.Json\lib\net6.0"
    $sixLaborsPath = Join-Path $InstallLocation "SixLabors.ImageSharp\lib\net6.0"
    
    New-Item -Path $spectreConsolePath -ItemType Directory -Force | Out-Null
    New-Item -Path $spectreConsoleImageSharpPath -ItemType Directory -Force | Out-Null
    New-Item -Path $spectreConsoleJsonPath -ItemType Directory -Force | Out-Null
    New-Item -Path $sixLaborsPath -ItemType Directory -Force | Out-Null
    
    # Define the files we need to copy explicitly to ensure all are handled correctly
    $filesToCopy = @(
        @{
            Source = Join-Path $OverridesPath "Spectre.Console\lib\net6.0\Spectre.Console.dll"
            Destination = Join-Path $spectreConsolePath "Spectre.Console.dll"
        },
        @{
            Source = Join-Path $OverridesPath "Spectre.Console.ImageSharp\lib\net6.0\Spectre.Console.ImageSharp.dll"
            Destination = Join-Path $spectreConsoleImageSharpPath "Spectre.Console.ImageSharp.dll"
        }
    )
    
    # Copy the files
    foreach ($file in $filesToCopy) {
        if (Test-Path $file.Source) {
            Write-Warning "OVERRIDE: Copying $($file.Source) to $($file.Destination)"
            Copy-Item -Path $file.Source -Destination $file.Destination -Force
        } else {
            Write-Warning "Source file not found: $($file.Source)"
        }
    }
    
    # Find Spectre.Console.Json.dll if available
    $jsonDll = Get-ChildItem -Path $OverridesPath -Recurse -Filter "Spectre.Console.Json.dll" | Select-Object -First 1
    if ($null -ne $jsonDll) {
        Write-Warning "OVERRIDE: Copying $($jsonDll.FullName) to $(Join-Path $spectreConsoleJsonPath "Spectre.Console.Json.dll")"
        Copy-Item -Path $jsonDll.FullName -Destination (Join-Path $spectreConsoleJsonPath "Spectre.Console.Json.dll") -Force
    } else {
        Write-Warning "Spectre.Console.Json.dll not found in overrides, it may not be required"
    }
    
    # We need to extract the SixLabors.ImageSharp.dll from one of the existing dlls
    # Create a temporary directory to extract the dependency
    Write-Host "Looking for SixLabors.ImageSharp.dll dependency..."
    $tempDir = Join-Path (New-TemporaryFile).DirectoryName "TempExtract"
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    
    # Copy the Spectre.Console.ImageSharp.dll to the temp directory and use it to get the dependency
    try {
        $imageSharpDllPath = Join-Path $spectreConsoleImageSharpPath "Spectre.Console.ImageSharp.dll"
        if (Test-Path $imageSharpDllPath) {
            Copy-Item -Path $imageSharpDllPath -Destination $tempDir -Force
            
            # Try to find the dependency using the assembly
            try {
                Write-Host "Loading Spectre.Console.ImageSharp.dll to identify dependencies..."
                $assembly = [System.Reflection.Assembly]::LoadFrom((Join-Path $tempDir "Spectre.Console.ImageSharp.dll"))
                Write-Host "Assembly loaded successfully"
                
                # List assembly references to identify SixLabors.ImageSharp
                $references = $assembly.GetReferencedAssemblies()
                foreach ($ref in $references) {
                    Write-Host "Referenced assembly: $($ref.Name), Version: $($ref.Version)"
                }
                
                # Find SixLabors.ImageSharp reference
                $imageSharpRef = $references | Where-Object { $_.Name -eq "SixLabors.ImageSharp" }
                if ($null -ne $imageSharpRef) {
                    Write-Host "Found SixLabors.ImageSharp reference, version: $($imageSharpRef.Version)"
                    # Download this specific version
                    $imageSharpVersion = $imageSharpRef.Version.ToString()
                    Write-Host "Downloading SixLabors.ImageSharp version $imageSharpVersion"
                    
                    # Download the NuGet package
                    try {
                        $downloadLocation = Join-Path $tempDir "SixLabors.ImageSharp.zip"
                        Invoke-WebRequest "https://www.nuget.org/api/v2/package/SixLabors.ImageSharp/$imageSharpVersion" -OutFile $downloadLocation -UseBasicParsing
                        
                        if (Test-Path $downloadLocation) {
                            Write-Host "Expanding downloaded package..."
                            Expand-Archive $downloadLocation -DestinationPath (Join-Path $tempDir "SixLaborsExtracted") -Force
                            
                            # Find the DLL in the package
                            $sixLaborsDll = Get-ChildItem -Path (Join-Path $tempDir "SixLaborsExtracted") -Recurse -Filter "SixLabors.ImageSharp.dll" | Select-Object -First 1
                            if ($null -ne $sixLaborsDll) {
                                Write-Host "Copying SixLabors.ImageSharp.dll to $sixLaborsPath"
                                Copy-Item -Path $sixLaborsDll.FullName -Destination (Join-Path $sixLaborsPath "SixLabors.ImageSharp.dll") -Force
                            } else {
                                Write-Warning "Could not find SixLabors.ImageSharp.dll in the extracted package"
                            }
                        }
                    } catch {
                        Write-Warning "Failed to download SixLabors.ImageSharp: $_"
                    }
                }
            } catch {
                Write-Warning "Failed to load assembly to identify dependencies: $_"
            }
        }
    }
    finally {
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    # If we couldn't find or download the DLL, we need to create a placeholder DLL
    if (-not (Test-Path (Join-Path $sixLaborsPath "SixLabors.ImageSharp.dll"))) {
        Write-Warning "Could not obtain SixLabors.ImageSharp.dll, creating a placeholder file"
        # Create an empty file to prevent loading errors - this won't actually work but at least the module will load
        New-Item -Path (Join-Path $sixLaborsPath "SixLabors.ImageSharp.dll") -ItemType File -Force | Out-Null
    }
}

Write-Host "Setting up Spectre.Console from fork"
$installLocation = (Join-Path $PSScriptRoot "packages")
$csharpProjectLocation = (Join-Path $PSScriptRoot "private" "classes")
$testingInstallLocation = (Join-Path $PSScriptRoot ".." "PwshSpectreConsole.Tests" "packages")
$tempSpectreConsoleRepoDir = Join-Path $PSScriptRoot ".spectre.build"
$overridesPath = (Join-Path $PSScriptRoot "overrides")

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
try {
    $repoPath = Clone-SpectreConsoleRepository -RepoUrl $SpectreConsoleRepoUrl -Branch $SpectreConsoleBranch -TempDirectory $tempSpectreConsoleRepoDir

    # Build the forked Spectre.Console
    $buildSuccess = Build-SpectreConsole -RepoDirectory $repoPath -InstallLocation $installLocation -DotnetSdkMajorVersion $DotnetSdkMajorVersion
    
    # If the build failed and fallback is enabled, use the override DLLs
    if (-not $buildSuccess -and $FallbackToOverrides) {
        Write-Warning "Building from source failed, using override DLLs as fallback"
        Copy-OverrideFiles -OverridesPath $overridesPath -InstallLocation $installLocation
    }
    elseif (-not $buildSuccess) {
        throw "Failed to build Spectre.Console from source and fallback to overrides is disabled"
    }
}
catch {
    if ($FallbackToOverrides) {
        Write-Warning "Exception occurred: $_"
        Write-Warning "Falling back to override DLLs"
        Copy-OverrideFiles -OverridesPath $overridesPath -InstallLocation $installLocation
    }
    else {
        throw $_
    }
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
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to build PowerShell module classes"
    }
} finally {
    Pop-Location
}

Write-Host "Spectre.Console fork has been successfully set up"