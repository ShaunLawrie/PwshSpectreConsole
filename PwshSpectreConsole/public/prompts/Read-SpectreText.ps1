function Read-SpectreText {
    <#
    .SYNOPSIS
    Prompts the user with a question and returns the user's input.
    :::caution
    I would advise against this and instead use `Read-Host` because the Spectre Console prompt doesn't have access to the PowerShell session history. This means that you can't use the up and down arrow keys to navigate through your previous commands.
    :::

    .DESCRIPTION
    This function uses Spectre Console to prompt the user with a question and returns the user's input.

    .PARAMETER Question
    The question to prompt the user with.

    .PARAMETER DefaultAnswer
    The default answer if the user does not provide any input.

    .PARAMETER AnswerColor
    The color of the user's answer input. The default behaviour uses the standard terminal text color.

    .PARAMETER AllowEmpty
    If specified, the user can provide an empty answer.

    .PARAMETER Choices
    An array of choices that the user can choose from. If specified, the user will be prompted with a list of choices to choose from, with validation.
    With autocomplete and can tab through the choices.

    .EXAMPLE
    # This will prompt the user with the question "What's your name?" and return the user's input. If the user does not provide any input, the function will return "Prefer not to say".
    Read-SpectreText -Question "What's your name?" -DefaultAnswer "Prefer not to say"

    .EXAMPLE
    # This will prompt the user with the question "What's your favorite color?" and return the user's input.
    Read-SpectreText -Question "What's your favorite color?" -AnswerColor "Cyan1" -Choices "Black", "Green","Magenta", "I'll never tell!"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreText")]
    param (
        [string] $Question = "What's your name?",
        [string] $DefaultAnswer,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $AnswerColor,
        [switch] $AllowEmpty,
        [string[]] $Choices
    )
    $spectrePrompt = [Spectre.Console.TextPrompt[string]]::new($Question)
    $spectrePrompt.DefaultValueStyle = [Spectre.Console.Style]::new($script:DefaultValueColor)
    if ($DefaultAnswer) {
        $spectrePrompt = [Spectre.Console.TextPromptExtensions]::DefaultValue($spectrePrompt, $DefaultAnswer)
    }
    if ($AnswerColor) {
        $spectrePrompt.PromptStyle = [Spectre.Console.Style]::new(($AnswerColor | Convert-ToSpectreColor))
    }
    $spectrePrompt.AllowEmpty = $AllowEmpty
    if ($null -ne $Choices) {
        $spectrePrompt = [Spectre.Console.TextPromptExtensions]::AddChoices($spectrePrompt, $Choices)
    }
    return Invoke-SpectrePromptAsync -Prompt $spectrePrompt
}
