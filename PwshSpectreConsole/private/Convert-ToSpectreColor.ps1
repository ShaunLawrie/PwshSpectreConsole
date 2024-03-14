using namespace Spectre.Console

<#
.SYNOPSIS
Converts a string representation of a color to a Color object.

.DESCRIPTION
This function takes a string representation of a color and converts it to a Color object. The input color can be in the form of a named color or a hexadecimal color code.

.PARAMETER Color
The color to convert. This parameter is mandatory and accepts input from the pipeline.

.EXAMPLE
'red' | Convert-ToSpectreColor

.EXAMPLE
'#FF0000' | Convert-ToSpectreColor

.EXAMPLE
[Color]::Salmon1 | Convert-ToSpectreColor
#>
function Convert-ToSpectreColor {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Color
    )
    try {
        # Just return the console color object
        if ($Color -is [Color]) {
            return $Color
        }
        # Already validated in validation attribute
        if ($Color.StartsWith("#")) {
            $hexString = $Color -replace '^#', ''
            $hexBytes = [System.Convert]::FromHexString($hexString)
            return [Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2])
        }

        # Validated in attribute as a real color already
        return [Color]::$Color
    } catch {
        return $script:AccentColor
    }
}
