function Test-SpectreSixelSupport {
    <#
    .SYNOPSIS
        Tests if the terminal supports Sixel graphics.
    .DESCRIPTION
        Tests if the terminal supports Sixel graphics. Sixel allows the terminal to display images.  
        Windows Terminal Preview and other terminals support sixel, see https://www.arewesixelyet.com/ for more.  
        Returns $true if the terminal supports Sixel graphics, otherwise $false.  
    #>
    [Reflection.AssemblyMetadata("title", "Test-SpectreSixelSupport")]
    param ()
    try {
        $response = Get-ControlSequenceResponse -ControlSequence "[c"
        return $response.Contains(";4;")
    } catch {
        return $false
    }
}