using module ".\private\attributes\ColorAttributes.psm1"
using module ".\private\attributes\BorderAttributes.psm1"
using module ".\private\attributes\SpinnerAttributes.psm1"

$script:AccentColor = [Spectre.Console.Color]::Blue
$script:DefaultValueColor = [Spectre.Console.Color]::Grey

foreach ($directory in @('private', 'public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}