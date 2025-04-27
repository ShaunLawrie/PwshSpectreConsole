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

    if ($script:SpectreRecordingType) {
        [Spectre.Console.AnsiConsole]::Write($RenderableObject)
        return
    }

    if ($CustomItemFormatter) {
        # ps1xml CustomItem formatters mangle the output because it uses the last character of the buffer width for itself
        $script:SpectreConsole.Profile.Width = $Host.UI.RawUI.BufferSize.Width - 10
    } else {
        $script:SpectreConsole.Profile.Width = $Host.UI.RawUI.BufferSize.Width
    }

    $script:SpectreConsole.Write($RenderableObject)
    $output = $script:SpectreConsoleWriter.ToString().TrimEnd()
    $null = $script:SpectreConsoleWriter.GetStringBuilder().Clear()

    # If it contains sixel data and is from the custom item formatter then we need to write it to the console directly :(
    # I'm not sure why this is the case but it's the only way to get the sixel data to render correctly at the moment
    # This also affects items using link data because long links get line broken and the link is lost and rendering gets mangled
    if (($output -like "*P0;1q*" -or $output -like "*]8;id=*") -and $CustomItemFormatter) {
        "`n" + $output + "`e[2A" | Out-Host
        return
    } else {
        return $output
    }
}