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