using module ".\completions\Transformers.psm1"

<#
.SYNOPSIS
Writes an object to the console using [Spectre.Console.AnsiConsole]::Write()

.DESCRIPTION
This function is required for mocking ansiconsole in unit tests that write objects to the console.

.PARAMETER RenderableObject
The renderable object to write to the console e.g. [Spectre.Console.BarChart]

.EXAMPLE
Write-SpectreConsoleOutput -Object "Hello, World!" -ForegroundColor Green -BackgroundColor Black
#>
function Write-AnsiConsole {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $RenderableObject,
        [switch] $CustomItemFormatter
    )

    if ($CustomItemFormatter) {
        # ps1xml CustomItem formatters mangle the output because it uses the last character of the buffer width for itself
        $script:SpectreConsole.Profile.Width = $Host.UI.RawUI.BufferSize.Width - 1
    } else {
        $script:SpectreConsole.Profile.Width = $Host.UI.RawUI.BufferSize.Width
    }

    $script:SpectreConsole.Write($RenderableObject)
    $output = $script:SpectreConsoleWriter.ToString()
    
    $output.ToString().TrimEnd()
    
    $null = $script:SpectreConsoleWriter.GetStringBuilder().Clear()
}