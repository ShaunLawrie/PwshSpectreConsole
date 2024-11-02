<#
.SYNOPSIS
    Tests if the terminal supports Sixel graphics.
.DESCRIPTION
    Tests if the terminal supports Sixel graphics.
#>
function Test-SixelCapabilities {
    $response = Get-ControlSequenceResponse -ControlSequence "[c"
    return $response.Contains(";4;")
}