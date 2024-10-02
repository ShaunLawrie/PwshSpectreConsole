function ConvertTo-SixelImage {
    <#
    .SYNOPSIS
    Converts an Image to Sixel format.

    .DESCRIPTION

    :::caution
    This is experimental.
    Experimental features are unstable and subject to change.
    :::

    .PARAMETER ImagePath
    The path to the image file to display.

    .PARAMETER ImageUrl
    The URL to the image file to display.
    If specified, the image is downloaded to a temporary file and then displayed.

    .PARAMETER Width
    The width of the image in pixels.
    The image is scaled to fit within this width while maintaining its aspect ratio.

    .EXAMPLE
    # **Example 1**
    ConvertTo-SixelImage -ImagePath ".\private\images\harveyspecter.gif"

    .EXAMPLE
    # **Example 2**
    # This example demonstrates how to display a static image in the console.
    ConvertTo-SixelImage -ImagePath ".\private\images\smiley.png"
    #>
    [Reflection.AssemblyMetadata('title', 'ConvertTo-SixelImage')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'ImagePath', Mandatory, Position = 0)]
        [Alias('Fullname','Path')]
        [string] $ImagePath,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Uri', Mandatory, Position = 0)]
        [Alias('Uri','Url')]
        [uri] $ImageUrl,
        [int] $Width = 400,
        [int] $MaxColors = 16777216 # should we default to 256?
    )
    process {
        try {
            if ($ImageUrl) {
                $ImagePath = New-TemporaryFile
                Invoke-WebRequest -Uri $ImageUrl -OutFile $ImagePath -ErrorAction Stop
            }
            $imagePathResolved = Resolve-Path $ImagePath -ErrorAction Stop
            [PwshSpectreConsole.Sixel.Convert]::ImgToSixel($imagePathResolved, $Width, $MaxColors)
        }
        catch {
            Write-Error $_
        }
        finally {
            if ($ImageUrl) {
                Remove-Item $ImagePath
            }
        }
    }
}
