Add-Type -Path (Join-Path $PSScriptRoot "packages/Spectre.Console/lib/netstandard2.0/Spectre.Console.dll")
Add-Type -Path (Join-Path $PSScriptRoot "packages/Spectre.Console.ImageSharp/lib/netstandard2.0/Spectre.Console.ImageSharp.dll")
Add-Type -Path (Join-Path $PSScriptRoot "packages/SixLabors.ImageSharp/lib/netstandard2.0/SixLabors.ImageSharp.dll")

foreach ($directory in @('private', 'public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object {
        . $_.FullName
    }
}