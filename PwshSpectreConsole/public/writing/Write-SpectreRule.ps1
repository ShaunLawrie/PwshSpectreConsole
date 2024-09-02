using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

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

    .PARAMETER PassThru
    Returns the Spectre Rule object instead of writing it to the console.

    .EXAMPLE
    # **Example 1**
    # This example demonstrates how to write a rule to the console.
    Write-SpectreRule -Title "My Rule" -Alignment Center -Color Yellow
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreRule")]
    param (
        [string] $Title,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [Spectre.Console.Color] $LineColor = $script:DefaultValueColor,
        [switch] $PassThru
    )
    $rule = [Spectre.Console.Rule]::new()
    if ($Title) {
        $rule.Title = "[$($Color.ToMarkup())]$Title[/]"
    }
    $rule.Style = [Spectre.Console.Style]::new($LineColor)
    $rule.Justification = [Spectre.Console.Justify]::$Alignment

    if ($PassThru) {
        return $rule
    }

    Write-AnsiConsole $rule
}