function Read-SpectrePause {
    <#
    .SYNOPSIS
    Pauses the script execution and waits for user input to continue.

    .DESCRIPTION
    The Read-SpectrePause function pauses the script execution and waits for user input to continue. It displays a message prompting the user to press the enter key to continue. If the end of the console window is reached, the function clears the message and moves the cursor up to the previous line.

    .PARAMETER Message
    The message to display to the user. The default message is "[<default value color>]Press [<accent color]<enter>[/] to continue[/]".

    .PARAMETER NoNewline
    Indicates whether to write a newline character before displaying the message. By default, a newline character is written.

    .EXAMPLE
    # This example pauses the script execution and displays the message "Press any key to continue...". The function waits for the user to press a key before continuing.
    Read-SpectrePause -Message "Press any key to continue..."
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectrePause")]
    param (
        [string] $Message = "[$($script:DefaultValueColor.ToMarkup())]Press [$($script:AccentColor.ToMarkup())]<enter>[/] to continue[/]",
        [switch] $NoNewline
    )

    # Drain input buffer so enter won't be pressed automatically
    Clear-InputQueue

    $position = $Host.UI.RawUI.CursorPosition
    if(!$NoNewline) {
        Write-Host ""
    }
    Write-SpectreHost $Message -NoNewline
    Read-Host
    $endPosition = $Host.UI.RawUI.CursorPosition
    if($endPosition -eq $position) {
        # Reached the end of the window
        Set-CursorPosition -X $position.X -Y ($position.Y - 2)
        Write-Host (" " * $Message.Length)
        Set-CursorPosition -X $position.X -Y ($position.Y - 2)
    } else {
        Set-CursorPosition -X $position.X -Y $position.Y
        Write-Host (" " * $Message.Length)
        Set-CursorPosition -X $position.X -Y $position.Y
    }
}