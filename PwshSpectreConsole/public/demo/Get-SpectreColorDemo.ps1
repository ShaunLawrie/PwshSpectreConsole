function Get-SpectreColorDemo {
    [Reflection.AssemblyMetadata("title", "Start-SpectreDemo")]
    param ()
    
    $colors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    $colors  = $colors | ForEach-Object {
        $prefix = ($_ -replace '[_0-9]+', '')
        $numeric = ($_ -replace '^[^0-9]+', '')
        $value = 0
        if([string]::IsNullOrEmpty($numeric)) {
            $value = 0.0
        } else {
            $numericParts = $numeric.Split('_')
            if($numericParts.Count -lt 2) {
                $value = [double]"$($numericParts[0]).9"
            } else {
                $value = [double]"$($numericParts[0]).$($numericParts[1])"
            }
        }
        return [pscustomobject]@{
            Name = $_
            Prefix = $prefix
            Numeric = $value
        }
    } | Sort-Object -Property @{Expression = "Prefix"}, @{Expression = "Numeric"} | Select-Object -ExpandProperty Name

    $maxLength = $colors | Measure-Object -Maximum -Property Length | Select-Object -ExpandProperty Maximum

    foreach($color in $colors) {
        $total = [Spectre.Console.Color]::$color | Select-Object @{ Name = "Total"; Expression = {$_.R + $_.G + $_.B} } | Select-Object -ExpandProperty Total
        $textColor = "white"
        if($total -gt 280) {
            $textColor = "black"
        }
        
        Write-SpectreHost -NoNewline "[$textColor on $color] $($color.PadRight($maxLength)) [/] "
        Write-SpectreHost ("[$color]$color[/]")
    }

    Write-Host "`nThe colors can be passed as the -Color parameter for most commands or used in Spectre Console markup like so:`n"
    Write-Host "  Input:  I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!"
    Write-SpectreHost "  Output: I am [Red]colored text[/] using [Yellow1 on Turquoise4]Spectre markdown[/]!"
    Write-SpectreHost "`nFor more markdown hints see [link]https://spectreconsole.net/markup[/]`n"
}