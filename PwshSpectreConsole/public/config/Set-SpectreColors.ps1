using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Set-SpectreColors {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/config/set-spectrecolors/')]
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
    # **Example 1**  
    # This example demonstrates how to set the accent color and default value color for Spectre Console.
    Write-SpectreRule "This is a default rule"
    Set-SpectreColors -AccentColor "Turquoise2"
    Write-SpectreRule "This is a Turquoise2 rule"
    Write-SpectreRule "This is a rule with a specified color" -Color "Yellow"

    #>
    [Reflection.AssemblyMetadata("title", "Set-SpectreColors")]
    param (
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $AccentColor = "Blue",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $DefaultValueColor = "Grey",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $DefaultTableHeaderColor = [Spectre.Console.Color]::Default,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $DefaultTableTextColor = [Spectre.Console.Color]::Default
    )
    $script:AccentColor = $AccentColor
    $script:DefaultValueColor = $DefaultValueColor
    $script:DefaultTableHeaderColor = $DefaultTableHeaderColor
    $script:DefaultTableTextColor = $DefaultTableTextColor
}