function Get-SpectreImageExperimental {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/images/get-spectreimageexperimental/')]
    <#
    .SYNOPSIS
    Displays an image in the console using block characters and ANSI escape codes.

    .DESCRIPTION
    This function loads an image from a file and displays it in the console using block characters and ANSI escape codes. The image is scaled to fit within the specified maximum width while maintaining its aspect ratio. If the image is an animated GIF, each frame is displayed in sequence.  
    The images rendered by this experimental function are not handled by Spectre Console, it's using a PowerShell script to render the image in a higher resolution than Spectre.Console does by using half-block characters.
    :::danger
    This has been deprecated and will be removed in PwshSpectreConsole v3.0.  
    :::

    .PARAMETER ImagePath
    The path to the image file to display.

    .PARAMETER ImageUrl
    The URL to the image file to display. If specified, the image is downloaded to a temporary file and then displayed.

    .PARAMETER Width
    The width of the image in characters. The image is scaled to fit within this width while maintaining its aspect ratio.

    .PARAMETER LoopCount
    The number of times to repeat the animation. The default value is 0, which means the animation will repeat forever. Press ctrl-c to stop the animation.

    .PARAMETER Resampler
    The resampling algorithm to use when scaling the image. Valid values are "Bicubic" and "NearestNeighbor". The default value is "Bicubic".

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to display an animated image in the console that loops 4 times.
    Get-SpectreImageExperimental -ImagePath ".\private\images\harveyspecter.gif" -LoopCount 4 -Width 82

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to display a static image in the console.
    Get-SpectreImageExperimental -ImagePath ".\private\images\smiley.png" -Width 80
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreImageExperimental")]
    param (
        [string] $ImagePath,
        [uri] $ImageUrl,
        [int] $Width,
        [int] $LoopCount = 0,
        [ValidateSet("Bicubic", "NearestNeighbor")]
        [string] $Resampler = "Bicubic"
    )

    Write-Warning "Get-SpectreImageExperimental has been deprecated and will be removed in PwshSpectreConsole v3.0. Use Get-SpectreImage instead."

    $spectreConsole = [Spectre.Console.AnsiConsole]::Console
    $spectreConsoleHeight = $spectreConsole.Profile.Height

    try {
        if ($ImageUrl) {
            $ImagePath = New-TemporaryFile
            Invoke-WebRequest -Uri $ImageUrl -OutFile $ImagePath
        }
        $imagePathResolved = Resolve-Path $ImagePath
        if (-not (Test-Path $imagePathResolved)) {
            throw "The specified image path '$resolvedImagePath' does not exist."
        }

        $backgroundColor = [System.Drawing.Color]::FromName([Console]::BackgroundColor)

        $image = [SixLabors.ImageSharp.Image]::Load($imagePathResolved)

        if ($Width) {
            $maxWidth = $Width
        } else {
            $maxWidth = $spectreConsole.Profile.Out.Width
            $Width = $image.Width
        }
        $maxHeight = ($spectreConsoleHeight) * 2
        $scaledHeight = [int]($image.Height * ($Width / $image.Width))
        if ($scaledHeight -gt $maxHeight) {
            $scaledHeight = $maxHeight
        }

        $scaledWidth = [int]($image.Width * ($scaledHeight / $image.Height))
        if ($scaledWidth -gt $maxWidth) {
            $scaledWidth = $maxWidth
            $scaledHeight = [int]($image.Height * ($scaledWidth / $image.Width))
        }

        [SixLabors.ImageSharp.Processing.ProcessingExtensions]::Mutate($image, {
                param($Context)
                [SixLabors.ImageSharp.Processing.ResizeExtensions]::Resize(
                    $Context,
                    $scaledWidth,
                    $scaledHeight,
                    [SixLabors.ImageSharp.Processing.KnownResamplers]::$Resampler
                )
            })

        $frames = [System.Collections.Generic.List[hashtable]]::new()
        $buffer = [System.Text.StringBuilder]::new($scaledWidth * $scaledHeight * 2)

        foreach ($frame in $image.Frames) {
            $frameDelayMilliseconds = 1000
            try {
                $frameMetadata = [SixLabors.ImageSharp.MetadataExtensions]::GetGifMetadata($frame.Metadata)
                if ($frameMetadata.FrameDelay) {
                    # The delay is supposed to be in milliseconds and imagesharp seems to be a bit out when it decodes it
                    $frameDelayMilliseconds = $frameMetadata.FrameDelay * 10
                }
            } catch {
                # Don't care
            }
            $buffer.Clear() | Out-Null
            for ($y = 0; $y -lt $scaledHeight; $y += 2) {
                if (($y + 1) -ge $scaledHeight) {
                    # The image is not an even number of pixels high and we're rendering two at a time, trim the last row if it's partial
                    $buffer.AppendLine() | Out-Null
                    break
                }
                for ($x = 0; $x -lt $scaledWidth; $x++) {
                    $currentPixel = $frame[$x, $y]
                    if ($null -ne $currentPixel.A) {
                        # Quick-hack blending the foreground with the terminal background color. This could be done in imagesharp
                        $foregroundMultiplier = $currentPixel.A / 255
                        $backgroundMultiplier = 100 - $foregroundMultiplier
                        $currentPixelRgb = @{
                            R = [math]::Min(255, ($currentPixel.R * $foregroundMultiplier + $backgroundColor.R * $backgroundMultiplier))
                            G = [math]::Min(255, ($currentPixel.G * $foregroundMultiplier + $backgroundColor.G * $backgroundMultiplier))
                            B = [math]::Min(255, ($currentPixel.B * $foregroundMultiplier + $backgroundColor.B * $backgroundMultiplier))
                        }
                    } else {
                        $currentPixelRgb = @{
                            R = $currentPixel.R
                            G = $currentPixel.G
                            B = $currentPixel.B
                        }
                    }

                    # Parse the image 2 vertical pixels at a time and use the lower half block character with varying foreground and background colors to
                    # make it appear as two pixels within one character space
                    if ($image.Height -ge ($y + 1)) {
                        $pixelBelow = $frame[$x, ($y + 1)]

                        if ($null -ne $pixelBelow.A) {
                            # Quick-hack blending the foreground with the terminal background color. This could be done in imagesharp
                            $foregroundMultiplier = $pixelBelow.A / 255
                            $backgroundMultiplier = 100 - $foregroundMultiplier
                            $pixelBelowRgb = @{
                                R = [math]::Min(255, ($pixelBelow.R * $foregroundMultiplier + $backgroundColor.R * $backgroundMultiplier))
                                G = [math]::Min(255, ($pixelBelow.G * $foregroundMultiplier + $backgroundColor.G * $backgroundMultiplier))
                                B = [math]::Min(255, ($pixelBelow.B * $foregroundMultiplier + $backgroundColor.B * $backgroundMultiplier))
                            }
                        } else {
                            $pixelBelowRgb = @{
                                R = $pixelBelow.R
                                G = $pixelBelow.G
                                B = $pixelBelow.B
                            }
                        }

                        $transparentCurrentPixel = $false
                        if($null -ne $pixelBelow.A -and $pixelBelow.A -lt 5) {
                            $buffer.Append("$([Char]27)[0m") | Out-Null
                            $transparentCurrentPixel = $true
                        } else {
                            $buffer.Append(("$([Char]27)[38;2;{0};{1};{2}m" -f
                                    $pixelBelowRgb.R,
                                    $pixelBelowRgb.G,
                                    $pixelBelowRgb.B
                                )) | Out-Null
                        }
                    } else {
                        $buffer.Append("$([Char]27)[0mX") | Out-Null
                        $transparentCurrentPixel = $true
                    }

                    if($transparentCurrentPixel -or ($null -ne $currentPixel.A -and $currentPixel.A -lt 5)) {
                        $buffer.Append("$([Char]27)[0m ") | Out-Null
                    } else {
                        $buffer.Append(("$([Char]27)[48;2;{0};{1};{2}m$([Char]0x2584)$([Char]27)[0m" -f
                                $currentPixelRgb.R,
                                $currentPixelRgb.G,
                                $currentPixelRgb.B
                            )) | Out-Null
                    }
                }
                $buffer.AppendLine() | Out-Null
            }

            $frames.Add(@{
                    FrameDelayMilliseconds = $frameDelayMilliseconds
                    Frame                  = $buffer.ToString().Trim()
                }
            )
        }

        $loopIterations = 0
        [Console]::CursorVisible = $false

        # Just one frame, print the image and return
        if ($frames.Count -eq 1) {
            $spectreConsole.Profile.Out.Writer.Write($frames[0].Frame)
            return
        }

        # The cursor needs to be returned to the top left of the image after every frame apart from the last
        $imageLines = $frames[0].Frame.Split("`n").Count - 1
        $returnLinesEscapeCode = "`r`e[${imageLines}A"
        do {
            $animationFrameReturnLines = $returnLinesEscapeCode
            for ($f = 0; $f -lt $frames.Count; $f++) {
                if($f -eq ($frames.Count - 1) -and $loopIterations -eq ($LoopCount - 1)) {
                    $animationFrameReturnLines = ""
                }
                $frame = $frames[$f]
                $spectreConsole.Profile.Out.Writer.Write($frame.Frame + $animationFrameReturnLines)
                Start-Sleep -Milliseconds $frame.FrameDelayMilliseconds
            }
            $loopIterations++
        } while ($loopIterations -lt $LoopCount -or $LoopCount -eq 0)
    } finally {
        [Console]::CursorVisible = $true
        if ($ImageUrl) {
            Remove-Item $ImagePath
        }
        Write-SpectreHost " "
    }
}