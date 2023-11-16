using module "..\..\private\attributes\ColorAttributes.psm1"
using module "..\..\private\attributes\BorderAttributes.psm1"

function Format-SpectrePanel {
    <#
    .SYNOPSIS
    Formats a string as a Spectre Console panel with optional title, border, and color.

    .DESCRIPTION
    This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.

    .PARAMETER Data
    The string to be formatted as a panel.

    .PARAMETER Title
    The title to be displayed at the top of the panel.

    .PARAMETER Border
    The type of border to be displayed around the panel. Valid values are "Rounded", "Heavy", "Double", "Single", "None".

    .PARAMETER Expand
    Switch parameter that specifies whether the panel should be expanded to fill the available space.

    .PARAMETER Color
    The color of the panel border.

    .EXAMPLE
    # This example displays a panel with the title "My Panel", a rounded border, and a red border color.
    Format-SpectrePanel -Data "Hello, world!" -Title "My Panel" -Border "Rounded" -Color "Red"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePanel")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Data,
        [string] $Title,
        [ValidateSpectreBorder()]
        [ArgumentCompletionsSpectreBorders()]
        [string] $Border = "Rounded",
        [switch] $Expand, 
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup()
    )
    $panel = [Spectre.Console.Panel]::new($Data)
    if($Title) {
        $panel.Header = [Spectre.Console.PanelHeader]::new($Title)
    }
    $panel.Expand = $Expand
    $panel.Border = [Spectre.Console.BoxBorder]::$Border
    $panel.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
    Write-AnsiConsole $panel
}