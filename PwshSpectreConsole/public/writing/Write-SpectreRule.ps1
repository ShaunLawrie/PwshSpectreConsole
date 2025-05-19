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

    .PARAMETER LineColor
    The color of the rule line. The default value is the default value color of the script.

    .PARAMETER Width
    The width of the rule. This can be specified as an integer (e.g., 80) or a percentage of the console width (e.g., '50%').

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
    # This example demonstrates how to write a rule with a percentage of the console width.
    Write-SpectreRule -Title "Half Width Rule" -Width "50%" -Alignment Center
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/writing/write-spectrerule/')]
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
        [ValidateScript({
            # Check if the value is a percentage
            if ($_ -is [string] -and $_ -match '^(\d+(\.\d+)?)%$') {
                $percentage = [double]$Matches[1]
                return $percentage -gt 0 -and $percentage -le 100
            }
            # Check if it's a valid integer
            if ($_ -is [int] -or ($_ -is [string] -and $_ -match '^\d+$')) {
                $intValue = [int]$_
                return $intValue -gt 0 -and $intValue -le (Get-HostWidth)
            }
            return $false
        }, ErrorMessage = "Width must be a positive integer not exceeding console width, or a percentage between 1% and 100%.")]
        $Width,
        [switch] $PassThru
    )
    $rule = [Spectre.Console.Rule]::new()
    if ($Title) {
        $rule.Title = "[$($Color.ToMarkup())]$Title[/]"
    }
    $rule.Style = [Spectre.Console.Style]::new($LineColor)
    $rule.Justification = [Spectre.Console.Justify]::$Alignment

    if ($Width) {
        # Calculate actual width based on input (integer or percentage)
        if ($Width -is [string] -and $Width -match '^(\d+(\.\d+)?)%$') {
            $percentage = [double]$Matches[1]
            $calculatedWidth = [math]::Floor((Get-HostWidth) * ($percentage / 100))
            $rule.Width = $calculatedWidth
        } else {
            $rule.Width = [int]$Width
        }
    }

    if ($PassThru) {
        return $rule
    }

    Write-AnsiConsole $rule
}