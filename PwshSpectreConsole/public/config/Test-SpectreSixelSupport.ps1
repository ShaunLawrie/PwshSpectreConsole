function Test-SpectreSixelSupport {
    <#
    .SYNOPSIS
        Tests if the terminal supports Sixel graphics.
    .DESCRIPTION
        Tests if the terminal supports Sixel graphics. Sixel allows the terminal to display images.  
        Windows Terminal Preview and other terminals support sixel, see https://www.arewesixelyet.com/ for more.  
        Returns $true if the terminal supports Sixel graphics, otherwise $false.  
    .EXAMPLE
        # **Example 1**  
        # This example demonstrates how to set the accent color and default value color for Spectre Console.  
        if (Test-SpectreSixelSupport) {
            Write-SpectreHost "Sixel graphics are supported :)"
        } else {
            Write-SpectreHost "Sixel graphics are not supported because this ran in Github Actions :("
        }
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