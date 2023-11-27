function Get-SpectreDemoEmoji {
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoEmoji")]
    param ()

    Write-Host ""
    Write-SpectreRule "`nGeneral"
    Write-Host ""
    
    $emojiCollection = [Spectre.Console.Emoji+Known] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    $faces = @()
    foreach($emoji in $emojiCollection) {
        $id = ($emoji -creplace '([A-Z])', '_$1' -replace '^_', '').ToLower()
        if($id -like "*face*") {
            $faces += $id
        } else {
            Write-SpectreHost ":${id}:`t$id"
        }
    }

    Write-Host ""
    Write-SpectreRule "Faces"
    Write-Host ""
    foreach($face in $faces) {
        Write-SpectreHost ":${face}:`t$face"
    }

    Write-Host ""
    Write-SpectreRule "Help"
    Write-Host ""
    Write-Host "The emoji can be used in Spectre Console markup like so:`n"
    # Apparently there is no way to escape emoji codes https://github.com/spectreconsole/spectre.console/issues/408
    Write-SpectreHost -NoNewline "  PS> [yellow]Write-Host[/] [DeepSkyBlue1]`"I am a :[/]"
    Write-SpectreHost -NoNewline "[DeepSkyBlue1]grinning_face: Spectre markdown emoji string :[/]"
    Write-SpectreHost "[DeepSkyBlue1]victory_hand: !`"[/]"
    Write-SpectreHost "  [white on grey19]I am a :grinning_face: Spectre markdown emoji string :victory_hand: !                                           [/]"
    Write-SpectreHost "`nEmoji support is dependent on OS, terminal & font support. For more markdown hints see [link]https://spectreconsole.net/markup[/] and for more emoji help see [link]https://spectreconsole.net/appendix/emojis[/]`n"
}