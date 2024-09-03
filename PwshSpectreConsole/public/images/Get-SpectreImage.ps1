
function Get-SpectreImage {
    <#
    .SYNOPSIS
    Displays an image in the console using CanvasImage.

    .DESCRIPTION
    Displays an image in the console using CanvasImage. The image can be resized to a maximum width if desired.

    .PARAMETER ImagePath
    The path to the image file to be displayed.

    .PARAMETER MaxWidth
    The maximum width of the image. If not specified, the image will be displayed at its original size.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to display an image in the console.
    Get-SpectreImage -ImagePath ".\private\images\smiley.png" -MaxWidth 40
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreImage")]
    param (
        [string] $ImagePath,
        [int] $MaxWidth
    )
    $imagePathResolved = Resolve-Path $ImagePath
    if (-not (Test-Path $imagePathResolved)) {
        throw "The specified image path '$resolvedImagePath' does not exist."
    }

    $image = [Spectre.Console.CanvasImage]::new($imagePathResolved)
    if ($MaxWidth) {
        $image.MaxWidth = $MaxWidth
    }
    
    return $image
}