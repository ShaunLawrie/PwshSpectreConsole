using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Read-SpectreText {
    <#
    .SYNOPSIS
    Prompts the user with a question and returns the user's input.

    .DESCRIPTION
    This function uses Spectre Console to prompt the user with a question and returns the user's input.
    :::caution
    I would advise against this and instead use `Read-Host` because the Spectre Console prompt doesn't have access to the PowerShell session history.  
    Without session history you can't use the up and down arrow keys to navigate through your previous commands.
    This text entry also doesn't allow you to use arrow keys to go back and forwards through the text you're entering.
    :::

    .PARAMETER Message
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
    # **Example 1**  
    # This example demonstrates a simple text prompt with a default answer.
    $name = Read-SpectreText -Message "What's your name?" -DefaultAnswer "Prefer not to say"
    # Type "↲" to provide no answer
    Write-SpectreHost "Your name is '$name'"

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates a simple text prompt with a default answer and a color.
    $favouriteColor = Read-SpectreText -Message "What's your favorite color?" -DefaultAnswer "pink"
    # Type "orange", "↲" to enter your favourite color
    Write-SpectreHost "Your favourite color is '$favouriteColor'"

    .EXAMPLE
    # **Example 3**  
    # This example demonstrates a simple text prompt with a default answer, a color, and a list of choices.
    $favouriteColor = Read-SpectreText -Message "What's your favorite color?" -AnswerColor "Cyan1" -Choices "Black", "Green", "Magenta", "I'll never tell!"
    # Type "orange", "↲", "magenta", "↲" to enter text that must match a choice in the choices list, orange will be rejected, magenta will be accepted
    Write-SpectreHost "Your favourite color is '$favouriteColor'"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreText")]
    param (
        [Parameter(Mandatory)]
        [Alias("Title", "Question", "Prompt")]
        [string] $Message,
        [string] $DefaultAnswer,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $AnswerColor,
        [switch] $AllowEmpty,
        [int] $TimeoutSeconds,
        [string[]] $Choices
    )
    $spectrePrompt = [Spectre.Console.TextPrompt[string]]::new($Message, [System.StringComparer]::InvariantCultureIgnoreCase)
    $spectrePrompt.DefaultValueStyle = [Spectre.Console.Style]::new($script:DefaultValueColor)
    if ($DefaultAnswer) {
        $spectrePrompt = [Spectre.Console.TextPromptExtensions]::DefaultValue($spectrePrompt, $DefaultAnswer)
    }
    if ($AnswerColor) {
        $spectrePrompt.PromptStyle = [Spectre.Console.Style]::new($AnswerColor)
    }
    $spectrePrompt.AllowEmpty = $AllowEmpty
    if ($null -ne $Choices) {
        $spectrePrompt = [Spectre.Console.TextPromptExtensions]::AddChoices($spectrePrompt, $Choices)
    }
    return Invoke-SpectrePromptAsync -Prompt $spectrePrompt -TimeoutSeconds $TimeoutSeconds
}
