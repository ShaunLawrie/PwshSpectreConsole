$script:CachedImages = @{}

function Get-SpectreSixelImage {
    <#
    .SYNOPSIS
    Displays an image in the console using SixelImage.

    .DESCRIPTION
    Displays an image in the console using SixelImage, this requires Windows Terminal Preview or another Sixel compatible terminal.  
    ![Spectre Sixel Example](/sixel.png)

    This uses a forked copy of Spectre.Console because Sixel is not supported yet https://github.com/spectreconsole/spectre.console/discussions/1671  
    :::caution
    This is experimental.  
    Experimental features are unstable and subject to change.
    :::

    .PARAMETER ImagePath
    The path to the image file to be displayed. This can be a local file path or a URL.

    .PARAMETER MaxWidth
    The maximum width of the image in character cells. If not specified, the image will be displayed at its original size or to fit inside the terminal width.
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreSixelImage")]
    param (
        [Parameter(Mandatory)]
        [string] $ImagePath,
        [int] $MaxWidth = (Get-HostWidth)
    )

    if (!(Test-SpectreSixelSupport)) {
        # check if it's windows terminal or not
        if ($env:WT_SESSION) {
            Write-SpectreHost "[yellow]WARNING: Sixel graphics are only supported in Windows Terminal Preview[/]" -PassThru
        } else {
            Write-SpectreHost "[yellow]WARNING: Sixel graphics are not supported in this terminal see https://www.arewesixelyet.com/[/]" -PassThru
        }
        return
    }
    
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

    $image = [Spectre.Console.SixelImage]::new($imagePathResolved)
    if ($MaxWidth) {
        $image.MaxWidth = $MaxWidth
    }
    
    return $image
}