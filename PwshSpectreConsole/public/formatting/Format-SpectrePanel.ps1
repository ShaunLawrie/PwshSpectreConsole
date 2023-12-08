using module "..\..\private\completions\Completers.psm1"

function Format-SpectrePanel {
    <#
    .SYNOPSIS
    Formats a string as a Spectre Console panel with optional title, border, and color.
    ![Spectre panel example](/panel.png)

    .DESCRIPTION
    This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.

    .PARAMETER Data
    The string to be formatted as a panel.

    .PARAMETER Title
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
    # This example displays a panel with the title "My Panel", a rounded border, and a red border color.
    Format-SpectrePanel -Data "Hello, world!" -Title "My Panel" -Border "Rounded" -Color "Red"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePanel")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Data,
        [string] $Title,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [switch] $Expand,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::BufferWidth }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int]$Width,
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::WindowHeight }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console height.")]
        [int]$Height
    )
    $panel = [Spectre.Console.Panel]::new($Data)
    if ($Title) {
        $panel.Header = [Spectre.Console.PanelHeader]::new($Title)
    }
    if ($width) {
        $panel.Width = $Width
    }
    if ($height) {
        $panel.Height = $Height
    }
    $panel.Expand = $Expand
    $panel.Border = [Spectre.Console.BoxBorder]::$Border
    $panel.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
    Write-AnsiConsole $panel
}
