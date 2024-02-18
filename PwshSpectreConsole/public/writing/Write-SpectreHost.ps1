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
    # This example writes the message "Hello, world!" to the console with the word world flashing blue with an underline followed by an emoji throwing a shaka.
    Write-SpectreHost -Message "Hello, [blue underline rapidblink]world[/]! :call_me_hand:"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreHost")]
    [Reflection.AssemblyMetadata("description", "The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Message,
        [switch] $NoNewline
    )

    if($NoNewline) {
        Write-SpectreHostInternalMarkup $Message
    } else {
        Write-SpectreHostInternalMarkupLine $Message
    }
}