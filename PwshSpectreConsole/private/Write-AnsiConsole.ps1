using namespace Spectre.Console

<#
.SYNOPSIS
Writes an object to the console using [AnsiConsole]::Write()

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.

.PARAMETER RenderableObject
The renderable object to write to the console e.g. [BarChart]

.EXAMPLE
Write-SpectreConsoleOutput -Object "Hello, World!" -ForegroundColor Green -BackgroundColor Black
#>
function Write-AnsiConsole {
    param(
        [Parameter(Mandatory)]
        [Rendering.Renderable] $RenderableObject
    )
    [AnsiConsole]::Write($RenderableObject)
}