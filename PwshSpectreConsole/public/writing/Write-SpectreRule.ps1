using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"
using namespace Spectre.Console

function Write-SpectreRule {
    <#
    .SYNOPSIS
    Writes a Spectre horizontal-rule to the console.

    .DESCRIPTION
    The Write-SpectreRule function writes a Spectre horizontal-rule to the console with the specified title, alignment, and color.

    .PARAMETER Title
    The title of the rule.

    .PARAMETER Alignment
    The alignment of the text in the rule. The default value is Left.

    .PARAMETER Color
    The color of the rule. The default value is the accent color of the script.

    .EXAMPLE
    Write-SpectreRule -Title "My Rule" -Alignment Center -Color Red
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreRule")]
    param (
        [Parameter(Mandatory)]
        [string] $Title,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [switch] $PassThru
    )
    $rule = [Rule]::new("[$($Color.ToMarkup())]$Title[/]")
    $rule.Justification = [Justify]::$Alignment

    if ($PassThru) {
        return $rule
    }

    Write-AnsiConsole $rule
}