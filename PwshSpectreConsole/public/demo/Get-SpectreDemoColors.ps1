
<#
.SYNOPSIS
    Retrieves a list of Spectre Console colors and displays them with their corresponding markup.
    ![Spectre color demo](/colors.png)

.DESCRIPTION
    The Get-SpectreDemoColors function retrieves a list of Spectre Console colors and displays them with their corresponding markup. 
    It also provides information on how to use the colors as parameters for commands or in Spectre Console markup.

.EXAMPLE
    # **Example 1**
    # This example demonstrates how to use Get-SpectreDemoColors to display a list of the built-in Spectre Console colors.
    Get-SpectreDemoColors
#>
function Get-SpectreDemoColors {
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoColors")]
    param ()

    Write-SpectreHost " "
    $width = Get-HostWidth
    $remainder = $width
    $colors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    $sortableColors = $colors | ForEach-Object {
        $color = [Spectre.Console.Color]::$_
        $hsv = Convert-RgbToHsv -Red $color.R -Green $color.G -Blue $color.B
        return [pscustomobject]@{
            Name = $_
            Color = $color
            Saturation = $hsv[1]
            ColorCategory = Get-ColorCategory -Hue $hsv[0] -Saturation $hsv[1] -Value $hsv[2]
            Lightness = Get-ColorLightness -Red $color.R -Green $color.G -Blue $color.B
        }
    }
    $colorCategories = $sortableColors | Group-Object ColorCategory
    $colorCategories | ForEach-Object {
        if ($_.Name -like "00 Grey*") {
            $sorted = $_.Group | Sort-Object -Property Lightness
        } else {
            $sorted = $_.Group | Sort-Object -Property Saturation -Descending
        }

        $sorted | ForEach-Object {
            $colorName = $_.Name
            $spaceRequired = $colorName.Length + 3
            $remainder -= $spaceRequired
            if ($remainder -le 0) {
                Write-SpectreHost "`n"
                $remainder = $width - $spaceRequired
            }

            $foreground = if (($_.Color.R + $_.Color.G + $_.Color.B) -gt 280) {
                "black"
            } else {
                "white"
            }

            Write-SpectreHost "[$foreground on #$($_.Color.ToHex())] $($_.Name) [/] " -NoNewline
        }
    }
    Write-SpectreHost "`n"
    Write-SpectreRule "Help"
    Write-SpectreHost " "

    Write-SpectreHost "The colors can be passed as the `"-Color`" parameter for most commands or used in Spectre Console markup like so:`n"
    Write-SpectreHost "  PS> [Yellow]Write-SpectreHost[/] [DeepSkyBlue1]`"$('I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!' | Get-SpectreEscapedText)`"[/]"
    Write-SpectreHost "  [white on grey19]I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!                                                          [/]"
    Write-SpectreHost "`nFor more markdown hints see [link]https://spectreconsole.net/markup[/]`n"
}