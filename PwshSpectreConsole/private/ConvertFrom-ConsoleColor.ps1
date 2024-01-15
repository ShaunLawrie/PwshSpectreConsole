function ConvertFrom-ConsoleColor {
    param(
        [int]$Color
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $consoleColors = @{
        30  = 'Black'
        31  = 'DarkRed'
        32  = 'DarkGreen'
        33  = 'DarkYellow'
        34  = 'DarkBlue'
        35  = 'DarkMagenta'
        36  = 'DarkCyan'
        37  = 'Gray'
        40  = 'Black'
        41  = 'DarkRed'
        42  = 'DarkGreen'
        43  = 'DarkYellow'
        44  = 'DarkBlue'
        45  = 'DarkMagenta'
        46  = 'DarkCyan'
        47  = 'Gray'
        90  = 'DarkGray'
        91  = 'Red'
        92  = 'Green'
        93  = 'Yellow'
        94  = 'Blue'
        95  = 'Magenta'
        96  = 'Cyan'
        97  = 'White'
        100 = 'DarkGray'
        101 = 'Red'
        102 = 'Green'
        103 = 'Yellow'
        104 = 'Blue'
        105 = 'Magenta'
        106 = 'Cyan'
        107 = 'White'
    }
    return $consoleColors[$Color]
}
