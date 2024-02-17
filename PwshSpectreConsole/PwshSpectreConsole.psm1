using module ".\private\completions\Completers.psm1"
using namespace Spectre.Console

$script:AccentColor             = [Color]::Blue
$script:DefaultValueColor       = [Color]::Grey
$script:DefaultTableHeaderColor = [Color]::Grey82
$script:DefaultTableTextColor   = [Color]::Grey39

foreach ($directory in @('private', 'public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}