function Convert-HslToRgb {
    param(
        [ValidateRange(0, 360)]
        [int] $Hue,
        [ValidateRange(0, 100)]
        [int] $Saturation,
        [ValidateRange(0, 100)]
        [int] $Lightness
    )

    $huePercent = $Hue / 360.0
    $saturationPercent = $Saturation / 100.0
    $lightnessPercent = $Lightness / 100.0

    if ($saturationPercent -eq 0) {
        $red = $lightnessPercent
        $green = $lightnessPercent
        $blue = $lightnessPercent
    } else {
        $q = if ($lightnessPercent -lt 0.5) {
            $lightnessPercent * (1 + $saturationPercent)
        } else {
            $lightnessPercent + $saturationPercent - ($lightnessPercent * $saturationPercent)
        }
        $p = 2 * $lightnessPercent - $q

        $red = Convert-PqtToRgb -P $p -Q $q -T ($huePercent + (1 / 3))
        $green = Convert-PqtToRgb -P $p -Q $q -T $huePercent
        $blue = Convert-PqtToRgb -P $p -Q $q -T ($huePercent - (1 / 3))
    }

    return @(
        [int]($red * 255),
        [int]($green * 255),
        [int]($blue * 255)
    )
}