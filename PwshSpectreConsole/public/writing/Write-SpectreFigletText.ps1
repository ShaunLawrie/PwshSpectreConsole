using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Write-SpectreFigletText {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/writing/write-spectrefiglettext/')]
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

    .PARAMETER PassThru
    Returns the Spectre Figlet text object instead of writing it to the console.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to write Figlet text to the console.
    Write-SpectreFigletText -Text "Hello Spectre!" -Alignment "Center" -Color "Red"

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to write Figlet text to the console using a custom Figlet font.
    Write-SpectreFigletText -Text "Whoa?!" -FigletFontPath "..\PwshSpectreConsole.Docs\src\assets\3d.flf"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreFigletText")]
    param (
        [string] $Text = "Hello Spectre!",
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [string] $FigletFontPath,
        [switch] $PassThru
    )
    $figletFont = Read-FigletFont -FigletFontPath $FigletFontPath
    $figletText = [Spectre.Console.FigletText]::new($figletFont, $Text)
    $figletText.Justification = [Spectre.Console.Justify]::$Alignment
    $figletText.Color = $Color

    if ($PassThru) {
        return $figletText
    }
    
    Write-AnsiConsole $figletText
}