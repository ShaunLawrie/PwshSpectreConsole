using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectrePanel {
    <#
    .SYNOPSIS
    Formats a string as a Spectre Console panel with optional title, border, and color.

    .DESCRIPTION
    This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.  
    See https://spectreconsole.net/widgets/panel for more information.

    .PARAMETER Data
    The renderable item to be formatted as a panel.

    .PARAMETER Header
    The title to be displayed at the top of the panel.

    .PARAMETER Border
    The type of border to be displayed around the panel.

    .PARAMETER Expand
    Switch parameter that specifies whether the panel should be expanded to fill the available space.

    .PARAMETER Color
    The color of the panel border.

    .PARAMETER Width
    The width of the panel.

    .PARAMETER Height
    The height of the panel.

    .EXAMPLE
    # **Example 1**
    # This example demonstrates how to display a panel with a title and a rounded border.
    Format-SpectrePanel -Data "Hello, world!" -Title "My Panel" -Border "Rounded" -Color "Red"

    .EXAMPLE
    # **Example 2**
    # This example demonstrates how to display a panel with a title and a double border that's expanded to take up the whole console width.
    "Hello, big panel!" | Format-SpectrePanel -Title "My Big Panel" -Border "Double" -Color "Magenta1" -Expand
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePanel")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [Alias("Title")]
        [string] $Header,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [switch] $Expand,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int]$Width,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostHeight) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console height.")]
        [int]$Height
    )
    
    process {
        $dataCollection = @($Data)
        foreach ($dataItem in $dataCollection) {
            $panel = [Spectre.Console.Panel]::new($dataItem)
            if ($Header) {
                $panel.Header = [Spectre.Console.PanelHeader]::new($Header)
            }
            if ($width) {
                $panel.Width = $Width
            }
            if ($height) {
                $panel.Height = $Height
            }
            $panel.Expand = $Expand
            $panel.Border = [Spectre.Console.BoxBorder]::$Border
            $panel.BorderStyle = [Spectre.Console.Style]::new($Color)
            return $panel
        }
    }
}
