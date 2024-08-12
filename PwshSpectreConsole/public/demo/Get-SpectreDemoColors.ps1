
<#
.SYNOPSIS
    Retrieves a list of Spectre Console colors and displays them with their corresponding markup.
    ![Spectre color demo](/colors.png)

.DESCRIPTION
    The Get-SpectreDemoColors function retrieves a list of Spectre Console colors and displays them with their corresponding markup. 
    It also provides information on how to use the colors as parameters for commands or in Spectre Console markup.

.PARAMETER Count
    Limit the number of colors returned. This is only really useful for generating the help docs.

.EXAMPLE
    Get-SpectreDemoColors -Count 4
#>
function Get-SpectreDemoColors {
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoColors")]
    param (
        [int] $Count
    )
    
    Write-SpectreHost " "
    Write-SpectreRule "Colors"
    Write-SpectreHost " "

    $colors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    if($Count) {
        $colors = $colors | Select-Object -First $Count
    }
    $colors = $colors | ForEach-Object {
        $prefix = ($_ -replace '[_0-9]+', '')
        $numeric = ($_ -replace '^[^0-9]+', '')
        $value = 0
        if ([string]::IsNullOrEmpty($numeric)) {
            $value = 0.0
        } else {
            $numericParts = $numeric.Split('_')
            if ($numericParts.Count -lt 2) {
                $value = [double]"$($numericParts[0]).9"
            } else {
                $value = [double]"$($numericParts[0]).$($numericParts[1])"
            }
        }
        return [pscustomobject]@{
            Name    = $_
            Prefix  = $prefix
            Numeric = $value
        }
    } | Sort-Object -Property @{Expression = "Prefix" }, @{Expression = "Numeric" } | Select-Object -ExpandProperty Name

    $maxLength = $colors | Measure-Object -Maximum -Property Length | Select-Object -ExpandProperty Maximum

    foreach ($color in $colors) {
        $total = [Spectre.Console.Color]::$color | Select-Object @{ Name = "Total"; Expression = { $_.R + $_.G + $_.B } } | Select-Object -ExpandProperty Total
        $textColor = "white"
        if ($total -gt 280) {
            $textColor = "black"
        }
        
        Write-SpectreHost -NoNewline "[$textColor on $color] $($color.PadRight($maxLength)) [/] "
        Write-SpectreHost ("[$color]$color[/]")
    }

    Write-SpectreHost " "
    Write-SpectreRule "Help"
    Write-SpectreHost " "

    Write-SpectreHost "The colors can be passed as the `"-Color`" parameter for most commands or used in Spectre Console markup like so:`n"
    Write-SpectreHost "  PS> [Yellow]Write-SpectreHost[/] [DeepSkyBlue1]`"$('I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!' | Get-SpectreEscapedText)`"[/]"
    Write-SpectreHost "  [white on grey19]I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!                                                          [/]"
    Write-SpectreHost "`nFor more markdown hints see [link]https://spectreconsole.net/markup[/]`n"
}