function Test-SpectreSixelSupport {
    <#
    .SYNOPSIS
        Tests if the terminal supports Sixel graphics.
    .DESCRIPTION
        Tests if the terminal supports Sixel graphics. Sixel allows the terminal to display images.  
        Windows Terminal Preview and other terminals support sixel, see https://www.arewesixelyet.com/ for more.  
        Returns $true if the terminal supports Sixel graphics, otherwise $false.  
    .EXAMPLE
        # **Check if the terminal supports Sixel graphics**  
        if (Test-SpectreSixelSupport) {
            Write-SpectreHost "Sixel graphics are supported :)"
        } else {
            Write-SpectreHost "Sixel graphics are not supported :("
        }
    #>
    [Reflection.AssemblyMetadata("title", "Set-SpectreColors")]
    param ()
    $response = Get-ControlSequenceResponse -ControlSequence "[c"
    return $response.Contains(";4;")
}