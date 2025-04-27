function Get-SpectreDemoEmoji {
    <#
    .SYNOPSIS
        Retrieves a collection of emojis available in Spectre Console.
        ![Example emojis](/emoji.png)

    .DESCRIPTION
        The Get-SpectreDemoEmoji function retrieves a collection of emojis available in Spectre Console. It displays the general emojis, faces, and provides information on how to use emojis in Spectre Console markup.

    .PARAMETER Count
        Limit the number of emoji returned. This is only really useful for generating the help docs.

    .EXAMPLE
        # **Example 1**  
        # This example demonstrates how to use Get-SpectreDemoEmoji to display a list of the built-in Spectre Console emojis.
        Get-SpectreDemoEmoji -Count 5

    .NOTES
        Emoji support is dependent on the operating system, terminal, and font support. For more information on Spectre Console markup and emojis, refer to the following links:
        - Spectre Console Markup: https://spectreconsole.net/markup
        - Spectre Console Emojis: https://spectreconsole.net/appendix/emojis
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/demo/get-spectredemoemoji/')]
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoEmoji")]
    param (
        [int] $Count
    )

    Write-SpectreHost " "
    Write-SpectreRule "`nEmoji"
    Write-SpectreHost " "
    
    $emojiCollection = [Spectre.Console.Emoji+Known] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    if($Count) {
        $emojiCollection = $emojiCollection | Select-Object -First $Count
    }
    $faces = @()
    foreach ($emoji in $emojiCollection) {
        $id = ($emoji -creplace '([A-Z])', '_$1' -replace '^_', '').ToLower()
        if ($id -like "*face*") {
            $faces += $id
        } else {
            Write-SpectreHost ":${id}:`t$id"
        }
    }

    Write-SpectreHost " "
    if($faces) {
        Write-SpectreRule "Faces"
        Write-SpectreHost " "
        foreach ($face in $faces) {
            Write-SpectreHost ":${face}:`t$face"
        }
    }

    Write-SpectreHost " "
    Write-SpectreRule "Help"
    Write-SpectreHost " "
    Write-SpectreHost "The emoji can be used in Spectre Console markup like so:`n"
    # Apparently there is no way to escape emoji codes https://github.com/spectreconsole/spectre.console/issues/408
    Write-SpectreHost -NoNewline "  PS> [yellow]Write-SpectreHost[/] [DeepSkyBlue1]`"I am a :[/]"
    Write-SpectreHost -NoNewline "[DeepSkyBlue1]grinning_face: Spectre markdown emoji string :[/]"
    Write-SpectreHost "[DeepSkyBlue1]victory_hand: !`"[/]"
    Write-SpectreHost "  [white on grey19]I am a :grinning_face: Spectre markdown emoji string :victory_hand: !                                                [/]"
    Write-SpectreHost "`nEmoji support is dependent on OS, terminal & font support. For more markdown hints see [link]https://spectreconsole.net/markup[/] and for more emoji help see [link]https://spectreconsole.net/appendix/emojis[/]`n"
}