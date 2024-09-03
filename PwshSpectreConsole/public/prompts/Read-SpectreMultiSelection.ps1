using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Read-SpectreMultiSelection {
    <#
    .SYNOPSIS
    Displays a multi-selection prompt using Spectre Console and returns the selected choices.

    .DESCRIPTION
    This function displays a multi-selection prompt using Spectre Console and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The function supports customizing the title, choices, choice label property, color, and page size of the prompt.

    .PARAMETER Title
    The title of the prompt. Defaults to "What are your favourite [Spectre.Console.Color]?".

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
    # **Example 1**  
    # This example demonstrates a multi-selection prompt with a custom title and choices.
    $fruits = Read-SpectreMultiSelection -Title "Select your favourite fruits" `
                                          -Choices @("apple", "banana", "orange", "pear", "strawberry", "durian", "lemon") `
                                          -PageSize 4
    # Type "↓", "<space>", "↓", "↓", "<space>", "↓", "<space>", "↲" to choose banana, pear and strawberry
    Write-SpectreHost "Your favourite fruits are $($fruits -join ', ')"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreMultiSelection")]
    param (
        [string] $Title = "What are your favourite [$($script:AccentColor.ToMarkup())]colors[/]?",
        [array] $Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet"),
        [string] $ChoiceLabelProperty,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [int] $PageSize = 5,
        [int] $TimeoutSeconds,
        [switch] $AllowEmpty
    )
    $spectrePrompt = [Spectre.Console.MultiSelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    $choiceObjects = $Choices | Where-Object { $_ -isnot [string] }
    if ($null -ne $choiceObjects -and [string]::IsNullOrEmpty($ChoiceLabelProperty)) {
        throw "You must specify the ChoiceLabelProperty parameter when using choice groups with complex objects"
    }
    if ($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
    }

    $spectrePrompt = [Spectre.Console.MultiSelectionPromptExtensions]::AddChoices($spectrePrompt, [string[]]$choiceLabels)
    $spectrePrompt.Title = $Title
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.Required = !$AllowEmpty
    $spectrePrompt.HighlightStyle = [Spectre.Console.Style]::new($Color)
    $spectrePrompt.InstructionsText = "[$($script:DefaultValueColor.ToMarkup())](Press [$($script:AccentColor.ToMarkup())]space[/] to toggle a choice and press [$($script:AccentColor.ToMarkup())]<enter>[/] to submit your answer)[/]"
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt -TimeoutSeconds $TimeoutSeconds

    if ($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object { $selected -contains $_.$ChoiceLabelProperty }
    }

    return $selected
}
