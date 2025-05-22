
<#
.SYNOPSIS
Starts an ANSI console live renderable.

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.
It ensures that the console has valid dimensions before starting the live display, which is particularly important in CI environments.

.PARAMETER Data
The renderable object to display.

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
    
    # Ensure console has valid dimensions before starting live display
    Initialize-SpectreConsoleDimensions
    
    try {
        [Spectre.Console.AnsiConsole]::Live($Data).Start({
            param (
                [Spectre.Console.LiveDisplayContext] $Context
            )
            Set-Variable -Name $resultVariableName -Value (& $ScriptBlock $Context) -Scope "Script"
        })
    }
    finally {
        # Dimensions are managed centrally via Initialize-SpectreConsoleDimensions
    }
    return Get-Variable -Name $resultVariableName -ValueOnly
}