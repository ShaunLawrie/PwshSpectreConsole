using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Set-SpectreColors {
    <#
    .SYNOPSIS
    Sets the accent color and default value color for Spectre Console.

    .DESCRIPTION
    This function sets the accent color and default value color for Spectre Console. The accent color is used for highlighting important information, while the default value color is used for displaying default values.

    An example of the accent color is the highlight used in `Read-SpectreSelection`:  
    ![Accent color example](/accentcolor.png)

    An example of the default value color is the default value displayed in `Read-SpectreText`:  
    ![Default value color example](/defaultcolor.png)

    .PARAMETER AccentColor
    The accent color to set. Must be a valid Spectre Console color name. Defaults to "Blue".

    .PARAMETER DefaultValueColor
    The default value color to set. Must be a valid Spectre Console color name. Defaults to "Grey".

    .EXAMPLE
    # Sets the accent color to Red and the default value color to Yellow.
    Set-SpectreColors -AccentColor Red -DefaultValueColor Yellow

    .EXAMPLE
    # Sets the accent color to Green and keeps the default value color as Grey.
    Set-SpectreColors -AccentColor Green
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
        [Color] $DefaultTableHeaderColor = "Grey82",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $DefaultTableTextColor = "Grey39"
    )
    $script:AccentColor = $AccentColor
    $script:DefaultValueColor = $DefaultValueColor
    $script:DefaultTableHeaderColor = $DefaultTableHeaderColor
    $script:DefaultTableTextColor = $DefaultTableTextColor
}