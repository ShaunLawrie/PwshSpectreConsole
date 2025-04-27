function Read-SpectrePause {
    <#
    .SYNOPSIS
    Pauses the script execution and waits for user input to continue.

    .DESCRIPTION
    The Read-SpectrePause function pauses the script execution and waits for user input to continue. It displays a message prompting the user to press the enter key to continue. If the end of the console window is reached, the function clears the message and moves the cursor up to the previous line.

    .PARAMETER Message
    The message to display to the user. The default message is "[default value color]Press [accent color]enter[/] to continue[/]".

    .PARAMETER NoNewline
    Indicates whether to write a newline character before displaying the message. By default, a newline character is written.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to use the Read-SpectrePause function.
    Read-SpectrePause -Message "Press the [red]enter[/] key to continue, when you press it this message will disappear..."
    # Type "↲" to dismiss the message

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to use the Read-SpectrePause function with the AnyKey parameter.
    Read-SpectrePause -Message "Press the [red]ANY[/] key to continue, when you press it this message will disappear..." -AnyKey
    # Type "x" to dismiss the message
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/prompts/read-spectrepause/')]
    [Reflection.AssemblyMetadata("title", "Read-SpectrePause")]
    param (
        [Alias("Title", "Question", "Prompt")]
        [string] $Message = "[$($script:DefaultValueColor.ToMarkup())]Press [$($script:AccentColor.ToMarkup())]<enter>[/] to continue[/]",
        [switch] $AnyKey,
        [switch] $NoNewline
    )

    $enterKey = 13

    # Drain input buffer so enter won't be pressed automatically
    Clear-InputQueue

    $returnLines = 2
    if (!$NoNewline) {
        Write-SpectreHost " "
        $returnLines++
    }
    Write-SpectreHost $Message -NoNewline
    do {
        $key = Read-ConsoleKey
        if($AnyKey) {
            break
        }
    } while (([int]$key.Key) -ne $enterKey)
    Write-SpectreHost ("`r" + (" " * $Message.Length))
    Write-SpectreHost ("`e[${returnLines}A" | Get-SpectreEscapedText)
}