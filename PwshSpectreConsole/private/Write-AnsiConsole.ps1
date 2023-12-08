<#
.SYNOPSIS
Writes an object to the console using [Spectre.Console.AnsiConsole]::Write()

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.

.PARAMETER RenderableObject
The renderable object to write to the console e.g. [Spectre.Console.BarChart]

.EXAMPLE
Write-SpectreConsoleOutput -Object "Hello, World!" -ForegroundColor Green -BackgroundColor Black

This example writes the string "Hello, World!" to the console with green foreground color and black background color.
#>
function Write-AnsiConsole {
    param(
        [Parameter(Mandatory)]
        [Spectre.Console.Rendering.Renderable] $RenderableObject
    )
    [Spectre.Console.AnsiConsole]::Write($RenderableObject)
}