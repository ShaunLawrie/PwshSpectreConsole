function Read-SpectreText {
    <#
    .SYNOPSIS
    Prompts the user with a question and returns the user's input.
    :::caution
    I would advise against this and instead use `Read-Host` because the Spectre Console prompt doesn't have access to the PowerShell session history. This means that you can't use the up and down arrow keys to navigate through your previous commands.
    :::

    .DESCRIPTION
    This function uses Spectre Console to prompt the user with a question and returns the user's input. The function takes two parameters: $Question and $DefaultAnswer. $Question is the question to prompt the user with, and $DefaultAnswer is the default answer if the user does not provide any input.

    .PARAMETER Question
    The question to prompt the user with.

    .PARAMETER DefaultAnswer
    The default answer if the user does not provide any input.

    .PARAMETER AllowEmpty
    If specified, the user can provide an empty answer.

    .EXAMPLE
    # This will prompt the user with the question "What's your name?" and return the user's input. If the user does not provide any input, the function will return "Prefer not to say".
    Read-SpectreText -Question "What's your name?" -DefaultAnswer "Prefer not to say"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreText")]
    param (
        [string] $Question = "What's your name?",
        [string] $DefaultAnswer,
        [switch] $AllowEmpty
    )
    $spectrePrompt = [Spectre.Console.TextPrompt[string]]::new($Question)
    $spectrePrompt.DefaultValueStyle = [Spectre.Console.Style]::new($script:DefaultValueColor)
    if ($DefaultAnswer) {
        $spectrePrompt = [Spectre.Console.TextPromptExtensions]::DefaultValue($spectrePrompt, $DefaultAnswer)
    }
    $spectrePrompt.AllowEmpty = $AllowEmpty
    return Invoke-SpectrePromptAsync -Prompt $spectrePrompt
}
