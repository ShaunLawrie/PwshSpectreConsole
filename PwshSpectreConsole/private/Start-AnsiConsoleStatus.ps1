function Start-AnsiConsoleStatus {
    param (
        [Parameter(Mandatory)]
        [string] $Title,
        [Parameter(Mandatory)]
        [Spectre.Console.Spinner] $Spinner,
        [Parameter(Mandatory)]
        [Spectre.Console.Style] $SpinnerStyle,
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    [Spectre.Console.AnsiConsole]::Status().Start($Title, {
        param (
            $ctx
        )
        $ctx.Spinner = $Spinner
        $ctx.SpinnerStyle = $SpinnerStyle
        & $ScriptBlock $ctx
    })
}
