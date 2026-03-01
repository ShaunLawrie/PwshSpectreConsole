#! /usr/bin/pwsh
param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    [string]$Task,
    [string[]] $FullNameFilter,
    [ValidateSet('Detailed', 'Diagnostic', 'Minimal', 'None', 'Normal')]
    [String] $PesterOutput
)

$ErrorActionPreference = 'Stop'

Write-Host "Build parameters: Configuration=$Configuration, Task=$Task, FullNameFilter=$($FullNameFilter -join ', '), PesterOutput=$PesterOutput" -ForegroundColor Cyan

# Helper function to build parameters for InvokeBuild
$buildparams = @{
    Configuration = $Configuration
    File          = Join-Path $PSScriptRoot 'PwshSpectreConsole.Src' 'Scripts' 'PwshSpectreConsole.build.ps1'
    Task          = 'All'
    Result        = 'Result'
    Safe          = $true
}

# Ensure InvokeBuild is installed
if (-not (Get-Module -ListAvailable -Name InvokeBuild)) {
    Write-Host "Installing InvokeBuild..." -ForegroundColor Yellow
    Install-Module -Name InvokeBuild -Scope CurrentUser -Force -AllowClobber
}

Import-Module InvokeBuild -ErrorAction Stop

if (-not (Get-Command dotnet)) {
    throw "dotnet CLI not found. Please install .NET SDK from https://dotnet.microsoft.com/download"
}
# Parse task argument
if ($task) {
    $buildparams.Task = $task
}
if ($FullNameFilter) {
    $buildparams['FullNameFilter'] = $FullNameFilter
}
if ($PesterOutput) {
    $buildparams['PesterOutput'] = $PesterOutput
}

Write-Host "Running build with configuration: $Configuration, buildParameters: $($buildparams | ConvertTo-Json -Depth 3)"

if (-not $env:CI) {
    # In local environment, run in separate PowerShell to allow rebuilds without restart
    $sb = {
        param($bp)
        Invoke-Build @bp
    }
    pwsh -NoProfile -Command $sb -args $buildparams
}
else {
    # In CI environment, run directly
    Invoke-Build @buildparams
    if ($Result.Error) {
        throw "Build failed with error: $($Result.Error)"
    }
}
