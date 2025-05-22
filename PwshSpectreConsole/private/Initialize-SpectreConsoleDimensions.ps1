<#
.SYNOPSIS
Initializes or ensures valid Spectre Console dimensions.

.DESCRIPTION
This function ensures that the Spectre Console has valid width and height dimensions.
If dimensions are invalid (0 or negative), it sets default values (80x24).
This is particularly important in CI environments where console dimensions may not be properly defined.

.PARAMETER DefaultWidth
The default width to use if the console width is invalid. Defaults to 80.

.PARAMETER DefaultHeight
The default height to use if the console height is invalid. Defaults to 24.
#>
function Initialize-SpectreConsoleDimensions {
    [CmdletBinding()]
    param (
        [int] $DefaultWidth = 80,
        [int] $DefaultHeight = 24
    )

    # Get current dimensions
    $width = [Spectre.Console.AnsiConsole]::Console.Profile.Width
    $height = [Spectre.Console.AnsiConsole]::Console.Profile.Height
    
    # Set default values if width or height is 0 or negative
    if ($width -le 0) {
        [Spectre.Console.AnsiConsole]::Console.Profile.Width = $DefaultWidth
    }
    
    if ($height -le 0) {
        [Spectre.Console.AnsiConsole]::Console.Profile.Height = $DefaultHeight
    }
}