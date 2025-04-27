using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectrePanel {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectrepanel/')]
    <#
    .SYNOPSIS
    Formats a string as a Spectre Console panel with optional title, border, and color.

    .DESCRIPTION
    This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.  
    This function takes a string or renderable object and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.  
    
    :::note  
    A panel can only contain a single renderable object. To combine multiple items (such as text and images) in one panel, you'll need to wrap them in a container like Format-SpectreRows or Format-SpectreColumns first. Without this wrapping, Format-SpectrePanel will render each item in a separate panel.
    :::  

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
      .EXAMPLE
    # **Example 3**  
    # This example demonstrates how to combine text and images in a single panel.
    # When combining multiple items in a panel, use Format-SpectreRows or Format-SpectreColumns to wrap them into a single renderable object.
    $message = "Thanks Jeff!"
    $image = Get-SpectreImage -ImagePath ".\private\images\smiley.png" -MaxWidth 25
    @($message, $image) | Format-SpectreRows | Format-SpectrePanel
    
    .EXAMPLE
    # **Example 4**  
    # This example demonstrates how to combine text and images in a single panel with side-by-side layout.
    $message = "Thanks Jeff!"
    $image = Get-SpectreImage -ImagePath ".\private\images\smiley.png" -MaxWidth 25  
    @($message, $image) | Format-SpectreColumns | Format-SpectrePanel
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
        [ValidateScript({ $_ -gt 0 }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative.")]
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
