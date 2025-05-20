using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Write-SpectreRule {
    <#
    .SYNOPSIS
    Writes a Spectre horizontal-rule to the console.

    .DESCRIPTION
    The Write-SpectreRule function writes a Spectre horizontal-rule to the console with the specified title, alignment, and color.
    You can control the width of the rule by specifying either the Width or WidthPercent parameter.

    .PARAMETER Title
    The title of the rule.

    .PARAMETER Alignment
    The alignment of the text in the rule. The default value is Left.

    .PARAMETER Color
    The color of the rule. The default value is the accent color of the script.

    .PARAMETER LineColor
    The color of the rule's line. The default value is the default value color of the script.

    .PARAMETER Width
    The width of the rule in characters. If not specified, the rule will span the full width of the console.
    Cannot be used together with WidthPercent.

    .PARAMETER WidthPercent
    The width of the rule as a percentage of the console width. Value must be between 1 and 100.
    Cannot be used together with Width.

    .PARAMETER PassThru
    Returns the Spectre Rule object instead of writing it to the console.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to write a rule to the console.
    Write-SpectreRule -Title "My Rule" -Alignment Center -Color Yellow

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to write a rule with a specific width.
    Write-SpectreRule -Title "Fixed Width Rule" -Width 40

    .EXAMPLE
    # **Example 3**  
    # This example demonstrates how to write a rule with a width that's a percentage of the console width.
    Write-SpectreRule -Title "Half Width Rule" -WidthPercent 50 -Alignment Center
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/writing/write-spectrerule/', DefaultParameterSetName = 'Default')]
    [Reflection.AssemblyMetadata("title", "Write-SpectreRule")]
    param (
        [string] $Title,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $LineColor = $script:DefaultValueColor,
        [Parameter(ParameterSetName = 'FixedWidth')]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $Width,
        [Parameter(ParameterSetName = 'PercentWidth')]
        [ValidateRange(1, 100)]
        [int] $WidthPercent,
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

    # Handle width customization
    if ($PSCmdlet.ParameterSetName -eq 'FixedWidth') {
        Write-AnsiConsoleWithWidth -RenderableObject $rule -MaxWidth $Width | Out-Host
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'PercentWidth') {
        $consoleWidth = [Console]::WindowWidth
        $calculatedWidth = [Math]::Floor($consoleWidth * ($WidthPercent / 100))
        # Ensure minimum width of 1
        $calculatedWidth = [Math]::Max(1, $calculatedWidth)
        Write-AnsiConsoleWithWidth -RenderableObject $rule -MaxWidth $calculatedWidth | Out-Host
    }
    else {
        Write-AnsiConsole -RenderableObject $rule
    }
}