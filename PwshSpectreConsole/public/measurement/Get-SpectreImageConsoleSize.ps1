function Get-SpectreImageConsoleSize {
    <#
    .SYNOPSIS
    Gets the dimensions of a Spectre Console image in console character cells.

    .DESCRIPTION
    The Get-SpectreImageConsoleSize function calculates how much space a Spectre Console image takes up in the console in terms of character cells.  
    This is particularly useful when you need to know how an image will be displayed in the console, rather than just its original pixel dimensions.  
    The function returns both the original image dimensions and the calculated console dimensions.

    .PARAMETER Image
    The Spectre Console image object to calculate the console dimensions for. This is typically the output from Get-SpectreImage.

    .PARAMETER ConsoleWidth
    The width of the console in characters. If not provided, the current console width will be used.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to get the console dimensions of an image.
    $image = Get-SpectreImage -ImagePath ".\private\images\smiley.png"
    $imageSize = $image | Get-SpectreImageConsoleSize
    Write-SpectreHost "Image pixel width: $($imageSize.PixelWidth), height: $($imageSize.PixelHeight)"
    Write-SpectreHost "Image console width: $($imageSize.ConsoleWidth), height: $($imageSize.ConsoleHeight)"
    $image | Out-SpectreHost
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/measurement/get-spectreimageconsolesize/')]
    [Reflection.AssemblyMetadata("title", "Get-SpectreImageConsoleSize")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Image,
        [Parameter()]
        [int] $ConsoleWidth = [Spectre.Console.AnsiConsole]::Console.Profile.Width
    )

    process {
        # Determine image type - if it has a MaxWidth property and it's set, use it
        $imageType = $Image.GetType().Name
        $originalWidth = $Image.Width
        $originalHeight = $Image.Height
        $maxWidth = if ($null -ne $Image.MaxWidth -and $Image.MaxWidth -gt 0) { $Image.MaxWidth } else { $ConsoleWidth }
        
        # Calculate console dimensions based on image type
        $consoleWidth = [Math]::Min($originalWidth, $maxWidth)
        $aspectRatio = $originalWidth / $originalHeight
        $consoleHeight = [Math]::Ceiling($consoleWidth / $aspectRatio)
        
        # Adjust based on image type
        if ($imageType -eq 'CanvasImage') {
            # CanvasImage is represented by character cells directly
        }
        elseif ($imageType -eq 'SixelImage') {
            # SixelImage uses pixel representation, but we still need to fit it in the console
            # The exact calculation might vary depending on terminal configurations
            # This is an estimation based on common sixel implementations
            $pixelWidth = $Image.PixelWidth
            if ($pixelWidth -gt 0) {
                $consoleWidth = [Math]::Ceiling($consoleWidth / $pixelWidth)
            }
        }
        
        # Make sure we don't exceed the console width
        if ($consoleWidth -gt $ConsoleWidth) {
            $consoleWidth = $ConsoleWidth
            $consoleHeight = [Math]::Ceiling($originalHeight * ($consoleWidth / $originalWidth))
        }
        
        # Return an object with both original and console dimensions
        return [PSCustomObject]@{
            PixelWidth = $originalWidth
            PixelHeight = $originalHeight
            ConsoleWidth = $consoleWidth
            ConsoleHeight = $consoleHeight
        }
    }
}