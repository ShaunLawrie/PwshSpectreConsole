using module "..\..\private\completions\Completers.psm1"

function Write-SpectreHost {
    <#
    .SYNOPSIS
    Writes a message to the console using Spectre Console markup.

    .DESCRIPTION
    The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.
    The markup language is defined at [https://spectreconsole.net/markup](https://spectreconsole.net/markup)
    Supported emoji are defined at [https://spectreconsole.net/appendix/emojis](https://spectreconsole.net/appendix/emojis)

    .PARAMETER Message
    The message to write to the console.

    .PARAMETER NoNewline
    If specified, the message will not be followed by a newline character.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to write a message to the console using Spectre Console markup.
    Write-SpectreHost -Message "Hello, [blue underline]world[/]! :call_me_hand:"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreHost")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Message,
        [switch] $NoNewline,
        [switch] $PassThru,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string]$Justify = "Left"
    )
    if ($NoNewline) {
        return Write-SpectreHostInternalMarkup $Message -Justify $Justify -PassThru:$PassThru
    } else {
        return Write-SpectreHostInternalMarkupLine $Message -Justify $Justify -PassThru:$PassThru
    }
}