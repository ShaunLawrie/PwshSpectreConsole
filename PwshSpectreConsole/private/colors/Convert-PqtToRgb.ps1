function Convert-PqtToRgb {
    param(
        [double] $P,
        [double] $Q,
        [double] $T
    )

    if ($T -lt 0) {
        $T += 1
    }
    if ($T -gt 1) {
        $T -= 1
    }

    if ($T -lt (1 / 6)) {
        return $P + ($Q - $P) * 6 * $T
    }
    if ($T -lt (1 / 2)) {
        return $Q
    }
    if ($T -lt (2 / 3)) {
        return $P + ($Q - $P) * (2 / 3 - $T) * 6
    }

    return $P
}