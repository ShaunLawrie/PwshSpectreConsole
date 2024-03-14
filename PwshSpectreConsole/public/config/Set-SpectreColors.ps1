using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Set-SpectreColors {
    <#
    .SYNOPSIS
    Sets the accent color and default value color for Spectre Console.

    .DESCRIPTION
    This function sets the accent color and default value color for Spectre Console. The accent color is used for highlighting important information, while the default value color is used for displaying default values.

    .PARAMETER AccentColor
    The accent color to set. Must be a valid Spectre Console color name. Defaults to "Blue".

    .PARAMETER DefaultValueColor
    The default value color to set. Must be a valid Spectre Console color name. Defaults to "Grey".

    .PARAMETER DefaultTableHeaderColor
    The default table header color to set. Must be a valid Spectre Console color name. Defaults to "Default" which will be the standard console foreground color.

    .PARAMETER DefaultTableTextColor
    The default table text color to set. Must be a valid Spectre Console color name. Defaults to "Default" which will be the standard console foreground color.

    .EXAMPLE
    Write-SpectreRule "This is a default rule"
    Set-SpectreColors -AccentColor "Turquoise2"
    Write-SpectreRule "This is a Turquoise2 rule"
    Write-SpectreRule "This is a rule with a specified color" -Color "Yellow"

    #>
    [Reflection.AssemblyMetadata("title", "Set-SpectreColors")]
    param (
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $AccentColor = "Blue",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $DefaultValueColor = "Grey",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $DefaultTableHeaderColor = [Color]::Default,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $DefaultTableTextColor = [Color]::Default
    )
    $script:AccentColor = $AccentColor
    $script:DefaultValueColor = $DefaultValueColor
    $script:DefaultTableHeaderColor = $DefaultTableHeaderColor
    $script:DefaultTableTextColor = $DefaultTableTextColor
}