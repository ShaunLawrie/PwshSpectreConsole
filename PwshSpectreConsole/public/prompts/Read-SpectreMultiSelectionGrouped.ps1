using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Read-SpectreMultiSelectionGrouped {
    <#
    .SYNOPSIS
    Displays a multi-selection prompt with grouped choices and returns the selected choices.

    .DESCRIPTION
    Displays a multi-selection prompt with grouped choices and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The choices can be grouped into categories, and the user can select choices from each category.

    .PARAMETER Message
    The title of the prompt. The default value is "What are your favourite [Spectre.Console.Color]?".

    .PARAMETER Choices
    An array of choice groups. Each group is a hashtable with two keys: "Name" and "Choices". The "Name" key is a string that represents the name of the group, and the "Choices" key is an array of strings that represents the choices in the group.

    .PARAMETER ChoiceLabelProperty
    The name of the property to use as the label for each choice. If this parameter is not specified, the choices are displayed as strings.

    .PARAMETER Color
    The color of the selected choices. The default value is the accent color of the script.

    .PARAMETER PageSize
    The number of choices to display per page. The default value is 10.

    .PARAMETER AllowEmpty
    Allow the multi-selection to be submitted without any options chosen.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates a multi-selection prompt with grouped choices.
    $selected = Read-SpectreMultiSelectionGrouped -Message "Select your favorite colors" -PageSize 8 -Choices @(
        @{
            Name = "Primary Colors"
            Choices = @("Red", "Blue", "Yellow")
        },
        @{
            Name = "Secondary Colors"
            Choices = @("Green", "Orange", "Purple")
        }
    )
    # Type "↓", "<space>", "↓", "↓", "↓", "<space>", "↲" to choose red and all secondary colors
    Write-SpectreHost "Your favourite colors are $($selected -join ', ')"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreMultiSelectionGrouped")]
    param (
        [Alias("Title", "Question", "Prompt")]
        [string] $Message,
        [Parameter(Mandatory)]
        [array] $Choices,
        [string] $ChoiceLabelProperty,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [int] $PageSize = 10,
        [int] $TimeoutSeconds,
        [switch] $AllowEmpty
    )
    $spectrePrompt = [Spectre.Console.MultiSelectionPrompt[string]]::new()

    $choiceLabels = $Choices.Choices
    $flattenedChoices = $Choices.Choices
    if ($ChoiceLabelProperty) {
        $choiceLabels = $choiceLabels | Select-Object -ExpandProperty $ChoiceLabelProperty
    }
    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made (even when using choice groups)"
    }

    foreach ($group in $Choices) {
        $choiceObjects = $group.Choices | Where-Object { $_ -isnot [string] }
        if ($null -ne $choiceObjects -and [string]::IsNullOrEmpty($ChoiceLabelProperty)) {
            throw "You must specify the ChoiceLabelProperty parameter when using choice groups with complex objects"
        }
        $choiceLabels = $group.Choices
        if ($ChoiceLabelProperty) {
            $choiceLabels = $choiceLabels | Select-Object -ExpandProperty $ChoiceLabelProperty
        }
        $spectrePrompt = [Spectre.Console.MultiSelectionPromptExtensions]::AddChoiceGroup($spectrePrompt, $group.Name, [string[]]$choiceLabels)
    }

    if ($Message) {
        $spectrePrompt.Title = $Message
    }
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.Required = !$AllowEmpty
    $spectrePrompt.HighlightStyle = [Spectre.Console.Style]::new($Color)
    $spectrePrompt.InstructionsText = "[$($script:DefaultValueColor.ToMarkup())](Press [$($script:AccentColor.ToMarkup())]space[/] to toggle a choice and press [$($script:AccentColor.ToMarkup())]<enter>[/] to submit your answer)[/]"
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt -TimeoutSeconds $TimeoutSeconds

    if ($ChoiceLabelProperty) {
        $selected = $flattenedChoices | Where-Object { $selected -contains $_.$ChoiceLabelProperty }
    }

    return $selected
}
