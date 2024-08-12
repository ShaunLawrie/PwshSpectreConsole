
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
    Write-SpectreHost -Message "Hello, [blue underline]world[/]! :call_me_hand:"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreHost")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Message,
        [switch] $NoNewline,
        [switch] $PassThru
    )

    if ($PassThru) {
        return $Message
    }

    if ($Message -is [Spectre.Console.Rendering.Renderable]) {
        Write-AnsiConsole $Message
        return
    }

    if ($NoNewline) {
        Write-SpectreHostInternalMarkup $Message
    } else {
        Write-SpectreHostInternalMarkupLine $Message
    }
}