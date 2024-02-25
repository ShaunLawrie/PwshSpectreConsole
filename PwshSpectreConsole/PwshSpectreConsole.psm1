using module ".\private\completions\Completers.psm1"
using namespace Spectre.Console

$script:AccentColor             = [Color]::Blue
$script:DefaultValueColor       = [Color]::Grey
$script:DefaultTableHeaderColor = [Color]::Default
$script:DefaultTableTextColor   = [Color]::Default

foreach ($directory in @('private', 'public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}