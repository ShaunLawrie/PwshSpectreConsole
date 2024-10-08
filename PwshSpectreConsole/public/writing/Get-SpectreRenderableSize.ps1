function Get-SpectreRenderableSize {
    <#
    .SYNOPSIS
    Gets the width and height of a Spectre Console widget.

    .DESCRIPTION
    The Get-SpectreRenderableSize function gets the height of a Spectre Console renderable object. The width and height is estimated.  
    This method of size calculation is not perfect, but it is a good approximation for most use cases. There are factors outside of the control of this function that can affect the size of the widget once it's rendered to the console.  
    The size of a containing object can influence the size of the widget when it's expandable. If you know the width and height of a container that this widget will be rendered inside you can provide that as a parameter to get a more accurate size.

    .PARAMETER Data
    The widget to calculate the size of.

    .PARAMETER ContainerHeight
    The height of the container that the widget will be rendered inside.

    .PARAMETER ContainerWidth
    The width of the container that the widget will be rendered inside.

    .EXAMPLE
    # **Example 1**  
    # This example calculates the height of a small panel
    $panel = "hello`nworld" | Format-SpectrePanel
    $panelSize = $panel | Get-SpectreRenderableSize
    Write-SpectreHost "Panel width: $($panelSize.Width), height: $($panelSize.Height)"
    $panel | Out-SpectreHost
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreRenderableSize")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [Spectre.Console.Rendering.Renderable] $Renderable,
        [int] $ContainerHeight = $script:SpectreConsole.Profile.Height,
        [int] $ContainerWidth = $script:SpectreConsole.Profile.Width
    )
    
    $size = [Spectre.Console.Size]::new($ContainerHeight, $ContainerWidth)
    $renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
        $script:SpectreConsole.Profile.Capabilities,
        $size
    )
    $renderOptions.Justification = $null
    $renderOptions.Height = $null

    $render = $Renderable.Render($renderOptions, $ContainerWidth)

    $lines = 0
    $maxLineWidth = 0
    $thisLineWidth = 0
    foreach ($segment in $render) {
        if ($segment.IsLineBreak) {
            if ($thisLineWidth -gt $maxLineWidth) {
                $maxLineWidth = $thisLineWidth
            }
            $thisLineWidth = 0
            $lines++
            continue
        }

        if (!$segment.IsControlCode) {
            $thisLineWidth += $segment.Text.Length
        }
    }

    return @{
        Height = $lines
        Width = $maxLineWidth
    }
}