using module "..\..\private\completions\Completers.psm1"

function Read-SpectreMultiSelection {
    <#
    .SYNOPSIS
    Displays a multi-selection prompt using Spectre Console and returns the selected choices.

    .DESCRIPTION
    This function displays a multi-selection prompt using Spectre Console and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The function supports customizing the title, choices, choice label property, color, and page size of the prompt.

    .PARAMETER Title
    The title of the prompt. Defaults to "What are your favourite [color]?".

    .PARAMETER Choices
    The list of choices to display in the selection prompt. ChoiceLabelProperty is required if the choices are complex objects rather than an array of strings.

    .PARAMETER ChoiceLabelProperty
    If the object is complex then the property of the choice object to use as the label in the selection prompt is required.

    .PARAMETER Color
    The color to use for highlighting the selected choices. Defaults to the accent color of the script.

    .PARAMETER PageSize
    The number of choices to display per page. Defaults to 5.

    .EXAMPLE
    # Displays a multi-selection prompt with the title "Select your favourite fruits", the list of fruits, the "Name" property as the label for each fruit, the color green for highlighting the selected fruits, and 3 fruits per page.
    Read-SpectreMultiSelection -Title "Select your favourite fruits" -Choices @("apple", "banana", "orange", "pear", "strawberry") -Color "Green" -PageSize 3
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreMultiSelection")]
    param (
        [string] $Title = "What are your favourite [$($script:AccentColor.ToMarkup())]colors[/]?",
        [array] $Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet"),
        [string] $ChoiceLabelProperty,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [int] $PageSize = 5
    )
    $prompt = [Spectre.Console.MultiSelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    if($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if($duplicateLabels) {
        Write-Error "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
        exit 2
    }

    $prompt = [Spectre.Console.MultiSelectionPromptExtensions]::AddChoices($prompt, [string[]]$choiceLabels)
    $prompt.Title = $Title
    $prompt.PageSize = $PageSize
    $prompt.WrapAround = $true
    $prompt.HighlightStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
    $prompt.InstructionsText = "[$($script:DefaultValueColor.ToMarkup())](Press [$($script:AccentColor.ToMarkup())]space[/] to toggle a choice and press [$($script:AccentColor.ToMarkup())]<enter>[/] to submit your answer)[/]"
    $prompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $prompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}