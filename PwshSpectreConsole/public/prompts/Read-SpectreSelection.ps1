using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Read-SpectreSelection {
    <#
    .SYNOPSIS
    Displays a selection prompt using Spectre Console.

    .DESCRIPTION
    This function displays a selection prompt using Spectre Console. The user can select an option from the list of choices provided. The function returns the selected option.  
    With the `-EnableSearch` switch, the user can search for choices in the selection prompt by typing the characters instead of just typing up and down arrows.

    .PARAMETER Title
    The title of the selection prompt.

    .PARAMETER Choices
    The list of choices to display in the selection prompt. ChoiceLabelProperty is required if the choices are complex objects rather than an array of strings.

    .PARAMETER ChoiceLabelProperty
    If the object is complex then the property of the choice object to use as the label in the selection prompt is required.

    .PARAMETER Color
    The color of the selected option in the selection prompt.

    .PARAMETER PageSize
    The number of choices to display per page in the selection prompt.

    .PARAMETER EnableSearch
    If this switch is present, the user can search for choices in the selection prompt by typing the characters instead of just typing up and down arrows.

    .PARAMETER SearchHighlightColor
    The color of the search highlight in the selection prompt. Defaults to a slightly brighter version of the accent color.

    .EXAMPLE
    # **Example 1**
    # This example demonstrates a selection prompt with a custom title and choices.
    $color = Read-SpectreSelection -Title "Select your favorite color" -Choices @("Red", "Green", "Blue") -Color "Green"
    # Type "↓", "↓", "↓", "↓", "↲" to wrap around the list and choose green
    Write-SpectreHost "Your chosen color is '$color'"

    .EXAMPLE
    # **Example 2**
    # This example demonstrates a selection prompt with a custom title and choices, and search enabled.
    $color = Read-SpectreSelection -Title "Select your favorite color" -Choices @("Blue", "Bluer", "Blue-est") -EnableSearch
    # Type "b", "l", "u", "e", "r", "↲" to choose "Bluer"
    Write-SpectreHost "Your chosen color is '$color'"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreSelection")]
    param (
        [string] $Title = "What's your favourite colour [$($script:AccentColor.ToMarkup())]option[/]?",
        [array] $Choices = @("red", "green", "blue"),
        [string] $ChoiceLabelProperty,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [int] $PageSize = 5,
        [switch] $EnableSearch,
        [int] $TimeoutSeconds,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $SearchHighlightColor = $script:AccentColor.Blend([Spectre.Console.Color]::White, 0.7)
    )
    $spectrePrompt = [Spectre.Console.SelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    if ($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
    }

    $spectrePrompt = [Spectre.Console.SelectionPromptExtensions]::AddChoices($spectrePrompt, [string[]]$choiceLabels)
    $spectrePrompt.Title = $Title
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.HighlightStyle = [Spectre.Console.Style]::new($Color)
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $spectrePrompt.SearchEnabled = $EnableSearch
    $spectrePrompt.SearchHighlightStyle = [Spectre.Console.Style]::new($SearchHighlightColor)

    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt -TimeoutSeconds $TimeoutSeconds

    if ($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}
