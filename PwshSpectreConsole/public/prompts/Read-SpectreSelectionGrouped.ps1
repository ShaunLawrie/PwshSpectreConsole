using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Read-SpectreSelectionGrouped {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/prompts/read-spectreselectiongrouped/')]
    <#
    .SYNOPSIS
    Displays a selection prompt using Spectre Console with groups.

    .DESCRIPTION
    This function displays a selection prompt using Spectre Console. The user can select an option from the list of choices provided. The function returns the selected option.  
    With the `-EnableSearch` switch, the user can search for choices in the selection prompt by typing the characters instead of just typing up and down arrows.

    .PARAMETER Message
    The title of the selection prompt.

    .PARAMETER ChoiceGroups
    The hashtable of choice groups to display in the selection prompt. The hashtable is a collection of string keys for each group name and an array of choices for each group as the values. ChoiceLabelProperty is required if the choices are complex objects rather than an array of strings.

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
    $choices = @{
        "Reds" = @("Crimson", "Ruby", "Scarlet")
        "Greens" = @("Lime", "Emerald", "Jade")
        "Blues" = @("Azure", "Cerulean", "Sapphire")
    }
    $color = Read-SpectreSelectionGrouped -Message "Select your favorite color" -Choices $choices -Color "Green"
    # Type "↓", "↓", "↓", "↓", "↲" to wrap around the list and choose green
    Write-SpectreHost "Your chosen color is '$color'"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreSelectionGrouped")]
    param (
        [Alias("Title", "Question", "Prompt")]
        [string] $Message,
        [Parameter(Mandatory)]
        [hashtable] $Choices,
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

    $choiceLabels = $Choices.Values | ForEach-Object { [array]$_ }
    if ($ChoiceLabelProperty) {
        $choiceLabels = $Choices.Values | ForEach-Object { [array]$_ } | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($duplicateLabels) {
        throw "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
    }

    foreach ($key in $Choices.Keys) {
        $spectrePrompt = [Spectre.Console.SelectionPromptExtensions]::AddChoiceGroup($spectrePrompt, $key, [string[]]$Choices[$key])
    }
    
    if ($Message) {
        $spectrePrompt.Title = $Message
    }
    $spectrePrompt = [Spectre.Console.SelectionPromptExtensions]::Mode($spectrePrompt, [Spectre.Console.SelectionMode]::Leaf)
    $spectrePrompt.PageSize = $PageSize
    $spectrePrompt.WrapAround = $true
    $spectrePrompt.HighlightStyle = [Spectre.Console.Style]::new($Color)
    $spectrePrompt.MoreChoicesText = "[$($script:DefaultValueColor.ToMarkup())](Move up and down to reveal more choices)[/]"
    $spectrePrompt.SearchEnabled = $EnableSearch
    $spectrePrompt.SearchHighlightStyle = [Spectre.Console.Style]::new($SearchHighlightColor)

    $selected = Invoke-SpectrePromptAsync -Prompt $spectrePrompt -TimeoutSeconds $TimeoutSeconds

    if ($ChoiceLabelProperty) {
        $selected = $Choices.Values | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}
