using namespace Spectre.Console

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
    $resultVariableName = "AnsiConsoleProgressResult-$([guid]::NewGuid())"
    New-Variable -Name $resultVariableName -Scope "Script"
    [AnsiConsole]::Progress().Start({
        param (
            $ctx
        )
        Set-Variable -Name $resultVariableName -Value (& $ScriptBlock $ctx) -Scope "Script"
    })
    return Get-Variable -Name $resultVariableName -ValueOnly
}