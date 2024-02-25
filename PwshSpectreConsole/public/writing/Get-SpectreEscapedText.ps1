using namespace Spectre.Console

function Get-SpectreEscapedText {
    <#
    .SYNOPSIS
    Escapes text for use in Spectre Console.
    [ShaunLawrie/PwshSpectreConsole/issues/5](https://github.com/ShaunLawrie/PwshSpectreConsole/issues/5)

    .DESCRIPTION
    This function escapes text for use where Spectre Console accepts markup. It is intended to be used as a helper function for other functions that output text to the console using Spectre Console which contains special characters that need escaping.
    See [https://spectreconsole.net/markup](https://spectreconsole.net/markup) for more information about the markup language used in Spectre Console.

    .PARAMETER Text
    The text to be escaped.

    .EXAMPLE
    # This example shows some data that requires escaping being embedded in a string passed to Format-SpectrePanel.
    $data = "][[][]]][[][][]["
    Format-SpectrePanel -Title "Unescaped data" -Data "I want escaped $($data | Get-SpectreEscapedText) [yellow]and[/] [red]unescaped[/] data"
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreEscapedText")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Text
    )
    return [Markup]::Escape($Text)
}