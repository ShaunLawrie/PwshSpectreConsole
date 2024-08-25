
<#
.SYNOPSIS
    Retrieves a list of Spectre Console colors and displays them with their corresponding markup.
    ![Spectre color demo](/colors.png)

.DESCRIPTION
    The Get-SpectreDemoColors function retrieves a list of Spectre Console colors and displays them with their corresponding markup. 
    It also provides information on how to use the colors as parameters for commands or in Spectre Console markup.

.EXAMPLE
    Get-SpectreDemoColors
#>
function Get-SpectreDemoColors {
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoColors")]
    param ()

    function Get-ColorCategory {
        param (
            [int] $Hue,
            [int] $Saturation,
            [int] $Value
        )
    
        $categories = @{
            "02 Red" = @(0..20 + 350..360)
            "03 Orange" = @(21..45)
            "04 Yellow" = @(46..60)
            "05 Green" = @(61..108)
            "06 Green2" = @(109..150)
            "07 Cyan" = @(151..190)
            "08 Blue" = @(191..220)
            "09 Blue2" = @(221..240)
            "10 Purple" = @(241..280)
            "11 Pink1" = @(281..300)
            "12 Pink" = @(301..350)
        }
    
        if ($Saturation -lt 15) {
            if ($Value -lt 40) {
                return "00 Grey"
            }
            return "00 GreyZMud"
        }
    
        foreach ($category in $categories.GetEnumerator()) {
            if ($Hue -in $category.Value) {
                $cat = $category.Key
                if ($Saturation -lt 2) {
                    $cat = $cat + "ZMud"
                }
                return $cat
            }
        }
    }

    function Convert-RgbToHsv {
        param(
            [int] $Red,
            [int] $Green,
            [int] $Blue
        )
    
        $redPercent = $Red / 255.0
        $greenPercent = $Green / 255.0
        $bluePercent = $Blue / 255.0
    
        $max = [Math]::Max([Math]::Max($redPercent, $greenPercent), $bluePercent)
        $min = [Math]::Min([Math]::Min($redPercent, $greenPercent), $bluePercent)
        $delta = $max - $min
    
        $hue = 0
        $saturation = 0
        $value = 0
    
        if ($delta -eq 0) {
            $hue = 0
        } elseif ($max -eq $redPercent) {
            $hue = 60 * ((($greenPercent - $bluePercent) / $delta) % 6)
        } elseif ($max -eq $greenPercent) {
            $hue = 60 * ((($bluePercent - $redPercent) / $delta) + 2)
        } elseif ($max -eq $bluePercent) {
            $hue = 60 * ((($redPercent - $greenPercent) / $delta) + 4)
        }
    
        if ($hue -lt 0) {
            $hue = 360 + $hue
        }
    
        if ($max -eq 0) {
            $saturation = 0
        } else {
            $saturation = $delta / $max * 100
        }
    
        $value = $max * 100
    
        return @(
            [int]$hue,
            [int]$saturation,
            [int]$value
        )
    }

    function Get-Lightness {
        param(
            [int] $Red,
            [int] $Green,
            [int] $Blue
        )
    
        $redPercent = $Red / 255.0
        $greenPercent = $Green / 255.0
        $bluePercent = $Blue / 255.0
    
        $max = [Math]::Max([Math]::Max($redPercent, $greenPercent), $bluePercent)
        $min = [Math]::Min([Math]::Min($redPercent, $greenPercent), $bluePercent)
        
        return ($max + $min) / 2
    }

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
            Lightness = Get-Lightness -Red $color.R -Green $color.G -Blue $color.B
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