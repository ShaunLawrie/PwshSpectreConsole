function Merge-HashtableDefaults {
    param(
        [hashtable] $UserStyle,
        [hashtable] $DefaultStyle
    )
    foreach ($key in $UserStyle.Keys) {
        if (-not $DefaultStyle.ContainsKey($key)) {
            Write-Warning "Key '$key' is not a valid default style property and will be ignored, styles must be one of $($DefaultStyle.Keys -join ', ')."
        }
    }
    foreach ($key in $DefaultStyle.Keys) {
        if (-not $UserStyle.ContainsKey($key)) {
            $UserStyle[$key] = $DefaultStyle[$key]
        }
    }
}
