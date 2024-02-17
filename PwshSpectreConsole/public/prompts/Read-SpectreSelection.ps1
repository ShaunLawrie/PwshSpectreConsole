using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Read-SpectreSelection {
    <#
    .SYNOPSIS
    Displays a selection prompt using Spectre Console.

    .DESCRIPTION
    This function displays a selection prompt using Spectre Console. The user can select an option from the list of choices provided. The function returns the selected option.

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

    .EXAMPLE
    # This command displays a selection prompt with the title "Select your favorite color" and the choices "Red", "Green", and "Blue". The active selection is colored in green.
    Read-SpectreSelection -Title "Select your favorite color" -Choices @("Red", "Green", "Blue") -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreSelection")]
    param (
        [string] $Title = "What's your favourite colour [$($script:AccentColor.ToMarkup())]option[/]?",
        [array] $Choices = @("red", "green", "blue"),
        [string] $ChoiceLabelProperty,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [int] $PageSize = 5
    )
    $spectrePrompt = [SelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    if($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
    }

    $spectrePrompt = [SelectionPromptExtensions]::AddChoices($spectrePrompt, [string[]]$choiceLabels)
    $spectrePrompt.Title = $Title
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.HighlightStyle = [Style]::new($Color)
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}
