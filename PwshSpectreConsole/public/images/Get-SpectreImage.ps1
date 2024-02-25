using namespace Spectre.Console

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
    # Displays the image located at "C:\Images\myimage.png" with a maximum width of 80 characters.
    Get-SpectreImage -ImagePath "C:\Images\myimage.png" -MaxWidth 80
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreImage")]
    param (
        [string] $ImagePath,
        [int] $MaxWidth
    )
    $image = [CanvasImage]::new($ImagePath)
    if($MaxWidth) {
        $image.MaxWidth = $MaxWidth
    }
    Write-AnsiConsole $image
}