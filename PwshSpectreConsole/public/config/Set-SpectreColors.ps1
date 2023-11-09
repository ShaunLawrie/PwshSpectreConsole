using module "..\..\private\attributes\ColorAttributes.psm1"

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

    .EXAMPLE
    # Sets the accent color to Red and the default value color to Yellow.
    Set-SpectreColors -AccentColor Red -DefaultValueColor Yellow

    .EXAMPLE
    # Sets the accent color to Green and keeps the default value color as Grey.
    Set-SpectreColors -AccentColor Green
    #>
    [Reflection.AssemblyMetadata("title", "Set-SpectreColors")]
    param (
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $AccentColor = "Blue",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $DefaultValueColor = "Grey"
    )
    $script:AccentColor = $AccentColor | Convert-ToSpectreColor
    $script:DefaultValueColor = $DefaultValueColor | Convert-ToSpectreColor
}