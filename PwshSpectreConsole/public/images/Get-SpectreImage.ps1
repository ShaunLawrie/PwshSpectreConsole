$script:CachedImages = @{}

function Get-SpectreImage {
    <#
    .SYNOPSIS
    Displays an image in the console using CanvasImage or SixelImage if the terminal supports Sixel.

    .DESCRIPTION
    Displays an image in the console using CanvasImage or SixelImage if the terminal supports Sixel.  
    The image can be resized to a maximum width if desired.  
    See https://www.arewesixelyet.com/ for Sixel support status for your terminal.  
      
    For SixelImage, the image will be displayed in the terminal using Sixel graphics which has a much higher resolution than CanvasImage.  
    ![Spectre Sixel Example](/sixel.png)

    .PARAMETER ImagePath
    The path to the image file to be displayed, as a local path or remote path using http/https.

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

    if ($ImagePath.StartsWith("http://") -or $ImagePath.StartsWith("https://")) {
        if (!$script:CachedImages.ContainsKey($ImagePath) -or -not (Test-Path $script:CachedImages[$ImagePath])) {
            $tempFile = New-TemporaryFile
            Invoke-WebRequest -Uri $ImagePath -UseBasicParsing -Outfile $tempFile -ProgressAction SilentlyContinue
            $script:CachedImages[$ImagePath] = $tempFile.FullName
        }
        $ImagePath = $script:CachedImages[$ImagePath]
    }

    $imagePathResolved = Resolve-Path $ImagePath
    if (-not (Test-Path $imagePathResolved)) {
        throw "The specified image path '$resolvedImagePath' does not exist."
    }

    $image = (Test-SpectreSixelSupport) ? [Spectre.Console.SixelImage]::new($imagePathResolved) : [Spectre.Console.CanvasImage]::new($imagePathResolved)

    if ($MaxWidth) {
        $image.MaxWidth = $MaxWidth
    }
    
    return $image
}