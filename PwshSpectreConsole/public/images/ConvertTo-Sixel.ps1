function ConvertTo-Sixel {
    <#
    .SYNOPSIS
    Converts an Image to Sixel format.

    .DESCRIPTION

    :::caution
    This is experimental.
    Experimental features are unstable and subject to change.
    :::

    .PARAMETER Path
    The path to the image file to display.

    .PARAMETER Url
    The URL to the image file to display.
    If specified, the image is downloaded to a temporary file and then displayed.

    .PARAMETER Width
    The width of the image in pixels.
    The image is scaled to fit within this width while maintaining its aspect ratio.

    .PARAMETER MaxColors
    The maximum number of colors to use in the image.
    Maximum supported colors is 256.

    .EXAMPLE
    # **Example 1**
    ConvertTo-SixelImage -Path ".\private\images\harveyspecter.gif"

    .EXAMPLE
    # **Example 2**
    # This example demonstrates how to display an image in the console.
    ConvertTo-Sixel -Path ".\private\images\smiley.png"
    #>
    [Reflection.AssemblyMetadata('title', 'ConvertTo-Sixel')]
    [CmdletBinding()]
    [Alias('cts')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path', Mandatory, Position = 0)]
        [Alias('Fullname','ImagePath')]
        [string] $Path,
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Url', Mandatory, Position = 0)]
        [Alias('Uri','ImageUrl')]
        [uri] $Url,
        [int] $Width = 400,
        [int] $MaxColors = 256
    )
    process {
        try {
            if ($Url) {
                $Path = New-TemporaryFile
                Invoke-WebRequest -Uri $Url -OutFile $Path -ErrorAction Stop
            }
            $PathResolved = Resolve-Path $Path -ErrorAction Stop
            [PwshSpectreConsole.Sixel.Convert]::ImgToSixel($PathResolved, $Width, $MaxColors)
        } catch {
            Write-Error $_
        } finally {
            if ($Url) {
                Remove-Item $Path
            }
        }
    }
}
