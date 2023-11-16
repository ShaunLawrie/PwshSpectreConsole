
<#
.SYNOPSIS
Starts an ANSI console progress bar.

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.

.PARAMETER ScriptBlock
The script block to execute while the progress bar is running.

.EXAMPLE
# This example starts an ANSI console progress bar and executes a long-running operation.
Start-AnsiConsoleProgress {
    # Some long-running operation
}
#>
function Start-AnsiConsoleProgress {
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    [Spectre.Console.AnsiConsole]::Progress().Start({
        param (
            $ctx
        )
        & $ScriptBlock $ctx
    })
}