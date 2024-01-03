# Read in a figlet font or just return the default built-in one
function Read-FigletFont {
    param (
        [string] $FigletFontPath
    )
    $figletFont = [Spectre.Console.FigletFont]::Default
    if($FigletFontPath) {
        if(!(Test-Path $FigletFontPath)) {
            throw "The specified Figlet font file '$FigletFontPath' does not exist"
        }
        $figletFont = [Spectre.Console.FigletFont]::Load($FigletFontPath)
    }
    return $figletFont
}