using module ".\completions\Completers.psm1"

<#
.SYNOPSIS
Converts a string representation of a color to a Spectre.Console.Color object.

.DESCRIPTION
This function takes a string representation of a color and converts it to a Spectre.Console.Color object. The input color can be in the form of a named color or a hexadecimal color code.

.PARAMETER Color
The color to convert. This parameter is mandatory and accepts input from the pipeline.

.EXAMPLE
# This example converts the string 'red' to a Spectre.Console.Color object.
'red' | Convert-ToSpectreColor

.EXAMPLE
# This example converts the hexadecimal color code '#FF0000' to a Spectre.Console.Color object.
'#FF0000' | Convert-ToSpectreColor

.EXAMPLE
# This example passes through and returns the original color, it's needed for backwards compatibility with the older way of doing things in this library.
[Spectre.Console.Color]::Salmon1 | Convert-ToSpectreColor
#>
function Convert-ToSpectreColor {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateSpectreColor()]
        [string] $Color
    )
    try {
        # Already validated in validation attribute
        if($Color.StartsWith("#")) {
            $hexString = $Color -replace '^#', ''
            $hexBytes = [System.Convert]::FromHexString($hexString)
            return [Spectre.Console.Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2])
        }

        # Validated in attribute as a real color already
        return [Spectre.Console.Color]::$Color
    } catch {
        return $script:AccentColor
    }
}
