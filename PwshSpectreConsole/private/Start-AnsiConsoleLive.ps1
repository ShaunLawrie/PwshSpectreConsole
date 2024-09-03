
<#
.SYNOPSIS
Starts an ANSI console live renderable.

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.

.PARAMETER ScriptBlock
The script block to execute while the live renderable is being rendered.
#>
function Start-AnsiConsoleLive {
    param (
        [Parameter(Mandatory)]
        [Spectre.Console.Rendering.Renderable] $Data,
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    $resultVariableName = "AnsiConsoleLiveResult-$([guid]::NewGuid())"
    New-Variable -Name $resultVariableName -Scope "Script"
    [Spectre.Console.AnsiConsole]::Live($Data).Start({
            param (
                [Spectre.Console.LiveDisplayContext] $Context
            )
            Set-Variable -Name $resultVariableName -Value (& $ScriptBlock $Context) -Scope "Script"
        })
    return Get-Variable -Name $resultVariableName -ValueOnly
}