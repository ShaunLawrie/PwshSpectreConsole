Add-Type -Path (Join-Path $PSScriptRoot "packages/lib/netstandard2.0/Spectre.Console.dll")

foreach ($directory in @('public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object {
        . $_.FullName
    }
}