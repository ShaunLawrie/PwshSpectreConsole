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