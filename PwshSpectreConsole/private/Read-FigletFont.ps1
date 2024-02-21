using namespace Spectre.Console

# Read in a figlet font or just return the default built-in one
function Read-FigletFont {
    param (
        [string] $FigletFontPath
    )
    $figletFont = [FigletFont]::Default
    if($FigletFontPath) {
        if(!(Test-Path $FigletFontPath)) {
            throw "The specified Figlet font file '$FigletFontPath' does not exist"
        }
        $figletFont = [FigletFont]::Load($FigletFontPath)
    }
    return $figletFont
}