$script:CachedImages = @{}

function Get-SpectreImage {
    <#
    .SYNOPSIS
    Displays an image in the console using CanvasImage or SixelImage if the terminal supports Sixel.

    .DESCRIPTION
    Displays an image in the console using CanvasImage or SixelImage if the terminal supports Sixel.
    The image can be resized to a maximum width if desired.

    Windows Terminal supports Sixel in the [latest preview builds](https://apps.microsoft.com/detail/9n8g5rfz9xk3) so it will be available in the production builds soon 🤞
    See https://www.arewesixelyet.com/ for Sixel support status for your terminal.

    .PARAMETER ImagePath
    The path to the image file to be displayed, as a local path or remote path using http/https.

    .PARAMETER MaxWidth
    The maximum width of the image. If not specified, the image will be displayed at its original size.

    .PARAMETER Format
    The preferred format to use when rendering the image.
    If not specified, the image will be rendered using Sixel if the terminal supports it, otherwise it will use Canvas.

    .PARAMETER Force
    Forces the image to be displayed using the specified format, even if we can't detect Sixel support in the terminal.

    .EXAMPLE
    # **Example 1**
    # When Sixel is not supported the image will use the standard Canvas renderer which draws the image using character cells to represent the image.
    Get-SpectreImage -ImagePath ".\private\images\smiley.png" -MaxWidth 40

    .EXAMPLE
    # **Example 2**
    # For Sixel images, the image returned by `Get-SpectreImage` will render a new frame every time it's drawn so if it's an animated GIF it will appear animated if you render it repeatedly and move the cursor back to the same start position before each image output.
    #
    # ![Spectre Sixel Example](/lapras-terminal.gif)
    #
    NORECORDING
    $image = Get-SpectreImage ".\private\images\lapras-pokemon.gif" -MaxWidth 50

    Clear-Host
    [Console]::CursorVisible = $false

    for($frame = 0; $frame -lt 100; $frame++) {
        [Console]::SetCursorPosition(0, 0)
        $image | Format-SpectrePanel -Title "Frame: $frame" -Color White | Out-SpectreHost
        Start-Sleep -Milliseconds 150
    }
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/images/get-spectreimage/')]
    [Reflection.AssemblyMetadata('title', 'Get-SpectreImage')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [Alias('Uri', 'FullName')]
        [string] $ImagePath,
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Width')]
        [int] $MaxWidth,
        [ValidateSet('Auto', 'Sixel', 'Canvas')]
        [string] $Format = 'Auto',
        [switch] $Force
    )
    process {
        if ($ImagePath.StartsWith('http://') -or $ImagePath.StartsWith('https://')) {
            if (!$script:CachedImages.ContainsKey($ImagePath) -or -not (Test-Path $script:CachedImages[$ImagePath])) {
                $tempFile = New-TemporaryFile
                Invoke-WebRequest -Uri $ImagePath -UseBasicParsing -OutFile $tempFile -ProgressAction SilentlyContinue
                $script:CachedImages[$ImagePath] = $tempFile.FullName
            }
            $ImagePath = $script:CachedImages[$ImagePath]
        }

        $imagePathResolved = $PSCmdlet.GetUnresolvedProviderPathFromPSPath($ImagePath)
        if (-not (Test-Path $imagePathResolved)) {
            throw "The specified image path '$imagePathResolved' does not exist."
        }

        $image = $null
        if ($Format -eq 'Auto') {
            if ($script:TerminalSupportsSixel -or $Force.IsPresent) {
                $image = [Spectre.Console.SixelImage]::new($imagePathResolved)
            } else {
                $image = [Spectre.Console.CanvasImage]::new($imagePathResolved)
            }
        } elseif ($Format -eq 'Sixel') {
            if ($script:TerminalSupportsSixel -or $Force.IsPresent) {
                $image = [Spectre.Console.SixelImage]::new($imagePathResolved)
            } else {
                throw 'Sixel format is not supported in this terminal.'
            }
        } elseif ($Format -eq 'Canvas') {
            $image = [Spectre.Console.CanvasImage]::new($imagePathResolved)
        }

        if ($MaxWidth) {
            $image.MaxWidth = $MaxWidth
        }

        $image
    }
}
