<#
.SYNOPSIS
Reads a control sequence response from the console.

.DESCRIPTION
Reads a control sequence response from the console.

.PARAMETER ControlSequence
The control sequence to send to the console.

.EXAMPLE
# **Example 1**
# This example demonstrates how to read a control sequence response from the console.
$response = Get-ControlSequenceResponse -ControlSequence "[c"
#>
function Get-ControlSequenceResponse {
    param (
        [Parameter(Mandatory)]
        [string] $ControlSequence
    )
    $char = $null
    [console]::Write([char]27 + $ControlSequence)
    $response = do {
            $char = [console]::ReadKey($true).KeyChar
            $char
        } while ($char -ne 'c' -and [Console]::KeyAvailable)
    return -join $response
}
