using module "..\..\private\attributes\ColorAttributes.psm1"

function Read-SpectreMultiSelectionGrouped {
    <#
    .SYNOPSIS
    Displays a multi-selection prompt with grouped choices and returns the selected choices.

    .DESCRIPTION
    Displays a multi-selection prompt with grouped choices and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The choices can be grouped into categories, and the user can select choices from each category.

    .PARAMETER Title
    The title of the prompt. The default value is "What are your favourite [color]?".

    .PARAMETER Choices
    An array of choice groups. Each group is a hashtable with two keys: "Name" and "Choices". The "Name" key is a string that represents the name of the group, and the "Choices" key is an array of strings that represents the choices in the group.

    .PARAMETER ChoiceLabelProperty
    The name of the property to use as the label for each choice. If this parameter is not specified, the choices are displayed as strings.

    .PARAMETER Color
    The color of the selected choices. The default value is the accent color of the script.

    .PARAMETER PageSize
    The number of choices to display per page. The default value is 10.

    .EXAMPLE
    # This example displays a multi-selection prompt with two groups of choices: "Primary Colors" and "Secondary Colors". The prompt uses the "Name" property of each choice as the label. The user can select one or more choices from each group.
    Read-SpectreMultiSelectionGrouped -Title "Select your favorite colors" -Choices @(
        @{
            Name = "Primary Colors"
            Choices = @("Red", "Blue", "Yellow")
        },
        @{
            Name = "Secondary Colors"
            Choices = @("Green", "Orange", "Purple")
        }
    )
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreMultiSelectionGrouped")]
    param (
        [string] $Title = "What are your favourite [$($script:AccentColor.ToMarkup())]colors[/]?",
        [array] $Choices = @(
            @{
                Name = "The rainbow"
                Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet")
            },
            @{
                Name = "The other colors"
                Choices = @("black", "grey", "white")
            }
        ),
        [string] $ChoiceLabelProperty,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [int] $PageSize = 10
    )
    $prompt = [Spectre.Console.MultiSelectionPrompt[string]]::new()

    $choiceLabels = $Choices.Choices
    if($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }
    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if($duplicateLabels) {
        Write-Error "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made (even when using choice groups)"
        exit 2
    }

    foreach($group in $Choices) {
        $choiceLabels = $group.Choices
        if($ChoiceLabelProperty) {
            $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
        }
        $prompt = [Spectre.Console.MultiSelectionPromptExtensions]::AddChoiceGroup($prompt, $group.Name, [string[]]$choiceLabels)
    }

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