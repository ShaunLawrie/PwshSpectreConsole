function ConvertFrom-ConsoleColor {
    param(
        [int]$Color
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $consoleColors = @{
        30 = 'Black'
        31 = 'Red'
        32 = 'Green'
        33 = 'Yellow'
        34 = 'Blue'
        35 = 'Magenta'
        36 = 'Cyan'
        37 = 'Gray'
        40 = 'Black'
        41 = 'Red'
        42 = 'Green'
        43 = 'Yellow'
        44 = 'Blue'
        45 = 'Magenta'
        46 = 'Cyan'
        47 = 'Gray'
        90 = 'DarkGray'
        91 = 'DarkRed'
        92 = 'DarkGreen'
        93 = 'DarkYellow'
        94 = 'DarkBlue'
        95 = 'DarkMagenta'
        96 = 'DarkCyan'
        97 = 'White'
        100 = 'DarkGray'
        101 = 'DarkRed'
        102 = 'DarkGreen'
        103 = 'DarkYellow'
        104 = 'DarkBlue'
        105 = 'DarkMagenta'
        106 = 'DarkCyan'
        107 = 'White'
    }
    return $consoleColors[$Color]
}
