function ConvertTo-Sixel {
    <#
    .SYNOPSIS
    Converts an Image to Sixel format.
    Supports bmp, gif, jpeg, pbm, png, tiff, tga, webp.

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

    .PARAMETER Force
    Bypasses the Sixel support detection and forces sixel output.
    This is useful for testing purposes, if for some reason your terminal does not implement DA1 response.

    .EXAMPLE
    # **Example 1**
    # This example demonstrates how to display an image in the console from a local file.
    ConvertTo-Sixel -Path ".\private\images\smiley.png"

    .EXAMPLE
    # **Example 2**
    # This example demonstrates how to display an image in the console from a URL.
    ConvertTo-Sixel -Uri 'https://imgs.xkcd.com/comics/git_commit.png' -Width 439
    #>
    [Reflection.AssemblyMetadata('title', 'ConvertTo-Sixel')]
    [CmdletBinding()]
    [Alias('cts')]
    param(
        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName = 'Path', Mandatory, Position = 0)]
        [Alias('Fullname')]
        [string] $Path,
        [Parameter(ParameterSetName = 'Url', Mandatory, Position = 0)]
        [Alias('Uri')]
        [uri] $Url,
        [int] $Width,
        [int] $MaxColors = 256,
        [switch] $Force
    )
    begin {
        if (-Not $Force -And -Not $script:SpectreProfile.DA1.Sixel) {
            $errorMessage = @(
                "Sixel not supported by your terminal,"
                if ($env:WT_SESSION) {
                    'upgrade to latest Windows Terminal Preview (v1.22.2702+)'
                }
                'to override DA1 detection use -Force (for testing..)'
            ) -join ' '
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    [System.Management.Automation.PSNotSupportedException]::new($errorMessage),
                    'SixelNotSupported',
                    [System.Management.Automation.ErrorCategory]::NotImplemented,
                    $script:SpectreProfile.DA1
                )
            )
        }
    }
    process {
        try {
            if ($Url) {
                $Path = New-TemporaryFile
                Invoke-WebRequest -Uri $Url -OutFile $Path -ErrorAction Stop
            }
            $PathResolved = Resolve-Path $Path -ErrorAction Stop
            if ($Width) {
                [PwshSpectreConsole.Sixel.Convert]::ImgToSixel($PathResolved, $MaxColors, $Width)
            }
            else {
                [PwshSpectreConsole.Sixel.Convert]::ImgToSixel($PathResolved, $MaxColors)
            }
        } catch {
            Write-Error $_
        } finally {
            if ($Url) {
                Remove-Item $Path
            }
        }
    }
}
