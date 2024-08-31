function Get-ColorLightness {
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