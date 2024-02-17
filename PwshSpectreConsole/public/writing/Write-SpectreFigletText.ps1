using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Write-SpectreFigletText {
    <#
    .SYNOPSIS
    Writes a Spectre Console Figlet text to the console.

    .DESCRIPTION
    This function writes a Spectre Console Figlet text to the console. The text can be aligned to the left, right, or center, and can be displayed in a specified color.

    .PARAMETER Text
    The text to display in the Figlet format.

    .PARAMETER Alignment
    The alignment of the text. The default value is "Left".

    .PARAMETER Color
    The color of the text. The default value is the accent color of the script.

    .PARAMETER FigletFontPath
    The path to the Figlet font file to use. If this parameter is not specified, the default built-in Figlet font is used.
    The figlet font format is usually *.flf, see https://spectreconsole.net/widgets/figlet for more.

    .EXAMPLE
    # Displays the text "Hello Spectre!" in the center of the console, in red color.
    Write-SpectreFigletText -Text "Hello Spectre!" -Alignment "Center" -Color "Red"

    .EXAMPLE
    # Displays the text "Woah!" using a custom figlet font.
    Write-SpectreFigletText -Text "Whoa?!" -FigletFontPath "C:\Users\shaun\Downloads\3d.flf"
     ██       ██ ██                          ████  ██
    ░██      ░██░██                         ██░░██░██
    ░██   █  ░██░██       ██████   ██████  ░██ ░██░██
    ░██  ███ ░██░██████  ██░░░░██ ░░░░░░██ ░░  ██ ░██
    ░██ ██░██░██░██░░░██░██   ░██  ███████    ██  ░██
    ░████ ░░████░██  ░██░██   ░██ ██░░░░██   ░░   ░░
    ░██░   ░░░██░██  ░██░░██████ ░░████████   ██   ██
    ░░       ░░ ░░   ░░  ░░░░░░   ░░░░░░░░   ░░   ░░ 
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreFigletText")]
    param (
        [string] $Text = "Hello Spectre!",
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [string] $FigletFontPath
    )
    $figletFont = Read-FigletFont -FigletFontPath $FigletFontPath
    $figletText = [FigletText]::new($figletFont, $Text)
    $figletText.Justification = [Justify]::$Alignment
    $figletText.Color = $Color
    Write-AnsiConsole $figletText
}