using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

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

    .PARAMETER AllowEmpty
    Allow the multi-selection to be submitted without any options chosen.

    .EXAMPLE
    # Displays a multi-selection prompt with the title "Select your favourite fruits", the list of fruits, the "Name" property as the label for each fruit, the color green for highlighting the selected fruits, and 3 fruits per page.
    Read-SpectreMultiSelection -Title "Select your favourite fruits" -Choices @("apple", "banana", "orange", "pear", "strawberry") -Color "Green" -PageSize 3
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreMultiSelection")]
    param (
        [string] $Title = "What are your favourite [$($script:AccentColor.ToMarkup())]colors[/]?",
        [array] $Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet"),
        [string] $ChoiceLabelProperty,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [int] $PageSize = 5,
        [switch] $AllowEmpty
    )
    $spectrePrompt = [MultiSelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    $choiceObjects = $Choices | Where-Object { $_ -isnot [string] }
    if($null -ne $choiceObjects -and [string]::IsNullOrEmpty($ChoiceLabelProperty)) {
        throw "You must specify the ChoiceLabelProperty parameter when using choice groups with complex objects"
    }
    if($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
    }

    $spectrePrompt = [MultiSelectionPromptExtensions]::AddChoices($spectrePrompt, [string[]]$choiceLabels)
    $spectrePrompt.Title = $Title
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.Required = !$AllowEmpty
    $spectrePrompt.HighlightStyle = [Style]::new($Color)
    $spectrePrompt.InstructionsText = "[$($script:DefaultValueColor.ToMarkup())](Press [$($script:AccentColor.ToMarkup())]space[/] to toggle a choice and press [$($script:AccentColor.ToMarkup())]<enter>[/] to submit your answer)[/]"
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object { $selected -contains $_.$ChoiceLabelProperty }
    }

    return $selected
}
