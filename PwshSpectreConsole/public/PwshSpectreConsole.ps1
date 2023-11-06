using module "..\private\Attributes.psm1"

$script:AccentColor = [Spectre.Console.Color]::Blue
$script:DefaultValueColor = [Spectre.Console.Color]::Grey

function Invoke-SpectrePromptAsync {
    param (
        [Parameter(Mandatory)]
        $Prompt
    )
    $cts = [System.Threading.CancellationTokenSource]::new()
    try {
        $task = $Prompt.ShowAsync([Spectre.Console.AnsiConsole]::Console, $cts.Token)
        while (-not $task.AsyncWaitHandle.WaitOne(200)) {
            # Waiting for the async task this way allows ctrl-c interrupts to continue to work within the single-threaded PowerShell world
        }
        return $task.GetAwaiter().GetResult()
    } finally {
        $cts.Cancel()
        $task.Dispose()
    }
}

function Set-SpectreColors {
    <#
    .SYNOPSIS
    Sets the accent color and default value color for Spectre Console.

    .DESCRIPTION
    This function sets the accent color and default value color for Spectre Console. The accent color is used for highlighting important information, while the default value color is used for displaying default values.

    .PARAMETER AccentColor
    The accent color to set. Must be a valid Spectre Console color name. Defaults to "Blue".

    .PARAMETER DefaultValueColor
    The default value color to set. Must be a valid Spectre Console color name. Defaults to "Grey".

    .EXAMPLE
    # Sets the accent color to Red and the default value color to Yellow.
    Set-SpectreColors -AccentColor Red -DefaultValueColor Yellow

    .EXAMPLE
    # Sets the accent color to Green and keeps the default value color as Grey.
    Set-SpectreColors -AccentColor Green
    #>
    [Reflection.AssemblyMetadata("title", "Set-SpectreColors")]
    param (
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $AccentColor = "Blue",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $DefaultValueColor = "Grey"
    )
    $script:AccentColor = [Spectre.Console.Color]::$AccentColor
    $script:DefaultValueColor = [Spectre.Console.Color]::$DefaultValueColor
}

function Write-SpectreRule {
    <#
    .SYNOPSIS
    Writes a Spectre horizontal-rule to the console.

    .DESCRIPTION
    The Write-SpectreRule function writes a Spectre horizontal-rule to the console with the specified title, alignment, and color.

    .PARAMETER Title
    The title of the rule.

    .PARAMETER Alignment
    The alignment of the text in the rule. Valid values are Left, Center, and Right. The default value is Left.

    .PARAMETER Color
    The color of the rule. The default value is the accent color of the script.

    .EXAMPLE
    # This example writes a Spectre rule with the title "My Rule", centered alignment, and red color.
    Write-SpectreRule -Title "My Rule" -Alignment Center -Color Red
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreRule")]
    param (
        [Parameter(Mandatory)]
        [string] $Title,
        [string] $Alignment = "Left",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )
    $rule = [Spectre.Console.Rule]::new("[$($Color)]$Title[/]")
    $rule.Justification = [Spectre.Console.Justify]::$Alignment
    [Spectre.Console.AnsiConsole]::Write($rule)
}

function Write-SpectreFigletText {
    <#
    .SYNOPSIS
    Writes a Spectre Console Figlet text to the console.

    .DESCRIPTION
    This function writes a Spectre Console Figlet text to the console. The text can be aligned to the left, right, or centered, and can be displayed in a specified color.

    .PARAMETER Text
    The text to display in the Figlet format.

    .PARAMETER Alignment
    The alignment of the text. Valid values are "Left", "Right", and "Centered". The default value is "Left".

    .PARAMETER Color
    The color of the text. The default value is the accent color of the script.

    .EXAMPLE
    # Displays the text "Hello Spectre!" in the center of the console, in red color.
    Write-SpectreFigletText -Text "Hello Spectre!" -Alignment "Centered" -Color "Red"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreFigletText")]
    param (
        [string] $Text = "Hello Spectre!",
        [string] $Alignment = "Left",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )
    $figletText = [Spectre.Console.FigletText]::new($Text)
    $figletText.Justification = switch($Alignment) {
        "Left" { [Spectre.Console.Justify]::Left }
        "Right" { [Spectre.Console.Justify]::Right }
        "Centered" { [Spectre.Console.Justify]::Center }
        default { Write-Error "Invalid alignment $Alignment" }
    }
    $figletText.Color = [Spectre.Console.Color]::$Color
    [Spectre.Console.AnsiConsole]::Write($figletText)
}

function Read-SpectreConfirm {
    <#
    .SYNOPSIS
    Displays a simple confirmation prompt with the option of selecting yes or no and returns a boolean representing the answer. 

    .DESCRIPTION
    Displays a simple confirmation prompt with the option of selecting yes or no. Additional options are provided to display either a success or failure response message in addition to the boolean return value.

    .PARAMETER Prompt
    The prompt to display to the user. The default value is "Do you like cute animals?".

    .PARAMETER DefaultAnswer
    The default answer to the prompt if the user just presses enter. The default value is "y".

    .PARAMETER ConfirmSuccess
    The text and markup to display if the user chooses yes. If left undefined, nothing will display.

    .PARAMETER ConfirmFailure
    The text and markup to display if the user chooses no. If left undefined, nothing will display.

    .EXAMPLE
    # This example displays a simple prompt. The user can select either yes or no [Y/n]. A different message is displayed based on the user's selection. The prompt uses the AnsiConsole.MarkupLine convenience method to support colored text and other supported markup. 
    $readSpectreConfirmSplat = @{
        Prompt = "Would you like to continue the preview installation of [#7693FF]PowerShell 7?[/]"
        ConfirmSuccess = "Woohoo! The internet awaits your elite development contributions."
        ConfirmFailure = "What kind of monster are you? How could you do this?"
    }
    Read-SpectreConfirm @readSpectreConfirmSplat
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreConfirm")]
    param (
        [String] $Prompt = "Do you like cute animals?",
        [ValidateSet("y", "n")]
        [string] $DefaultAnswer = "y",
        [string] $ConfirmSuccess,
        [string] $ConfirmFailure
    )

    # This is much fiddlier but it exposes the ability to set the color scheme. The confirmationprompt is just a textprompt with two choices hard coded to y/n:
    # https://github.com/spectreconsole/spectre.console/blob/63b940cf0eb127a8cd891a4fe338aa5892d502c5/src/Spectre.Console/Prompts/ConfirmationPrompt.cs#L71
    $confirmationPrompt = [Spectre.Console.TextPrompt[string]]::new($Prompt)
    $confirmationPrompt = [Spectre.Console.TextPromptExtensions]::DefaultValue($confirmationPrompt, $DefaultAnswer)
    $confirmationPrompt = [Spectre.Console.TextPromptExtensions]::AddChoice($confirmationPrompt, "y")
    $confirmationPrompt = [Spectre.Console.TextPromptExtensions]::AddChoice($confirmationPrompt, "n")

    # This is how I added the default colors with Set-SpectreColors so you don't have to keep passing them through and get a consistent TUI color scheme
    $confirmationPrompt.DefaultValueStyle = [Spectre.Console.Style]::new($script:DefaultValueColor)
    $confirmationPrompt.ChoicesStyle = [Spectre.Console.Style]::new($script:AccentColor)
    $confirmationPrompt.InvalidChoiceMessage = "[red]Please select one of the available options[/]"

    # Invoke-SpectrePromptAsync supports ctrl-c
    $sprompt = (Invoke-SpectrePromptAsync -Prompt $confirmationPrompt) -eq "y"

    if(!$sprompt){
        if(![String]::IsNullOrWhiteSpace($ConfirmFailure)){
            [Spectre.Console.AnsiConsole]::MarkupLine($ConfirmFailure)
        }
    }else{
        if(![String]::IsNullOrWhiteSpace($ConfirmSuccess)){
            [Spectre.Console.AnsiConsole]::MarkupLine($ConfirmSuccess)
        }
    }

    return $sprompt
}

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
        [string] $Title = "What's your favourite colour [$($script:AccentColor.ToString())]option[/]?",
        [array] $Choices = @("red", "green", "blue"),
        [string] $ChoiceLabelProperty,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString(),
        [int] $PageSize = 5
    )
    $prompt = [Spectre.Console.SelectionPrompt[string]]::new()

    $choiceLabels = $Choices
    if($ChoiceLabelProperty) {
        $choiceLabels = $Choices | Select-Object -ExpandProperty $ChoiceLabelProperty
    }

    $duplicateLabels = $choiceLabels | Group-Object | Where-Object { $_.Count -gt 1 }
    if($duplicateLabels) {
        Write-Error "You have duplicate labels in your select list, this is ambiguous so a selection cannot be made"
        exit 2
    }

    $prompt = [Spectre.Console.SelectionPromptExtensions]::AddChoices($prompt, [string[]]$choiceLabels)
    $prompt.Title = $Title
    $prompt.PageSize = $PageSize
    $prompt.WrapAround = $true
    $prompt.HighlightStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
    $prompt.MoreChoicesText = "[$($script:DefaultValueColor)](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $prompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}

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
        [string] $Title = "What are your favourite [$($script:AccentColor.ToString())]colors[/]?",
        [array] $Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet"),
        [string] $ChoiceLabelProperty,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString(),
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
    $prompt.HighlightStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
    $prompt.InstructionsText = "[$($script:DefaultValueColor)](Press [$($script:AccentColor.ToString())]space[/] to toggle a choice and press [$($script:AccentColor.ToString())]<enter>[/] to submit your answer)[/]"
    $prompt.MoreChoicesText = "[$($script:DefaultValueColor)](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $prompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}

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
        [string] $Title = "What are your favourite [$($script:AccentColor.ToString())]colors[/]?",
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
        [string] $Color = $script:AccentColor.ToString(),
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
    $prompt.HighlightStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
    $prompt.InstructionsText = "[$($script:DefaultValueColor)](Press [$($script:AccentColor.ToString())]space[/] to toggle a choice and press [$($script:AccentColor.ToString())]<enter>[/] to submit your answer)[/]"
    $prompt.MoreChoicesText = "[$($script:DefaultValueColor)](Move up and down to reveal more choices)[/]"
    $selected = Invoke-SpectrePromptAsync -Prompt $prompt

    if($ChoiceLabelProperty) {
        $selected = $Choices | Where-Object -Property $ChoiceLabelProperty -Eq $selected
    }

    return $selected
}

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

    .EXAMPLE
    # This will prompt the user with the question "What's your name?" and return the user's input. If the user does not provide any input, the function will return "Prefer not to say".
    Read-SpectreText -Question "What's your name?" -DefaultAnswer "Prefer not to say"
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectreText")]
    param (
        [string] $Question = "What's your name?",
        [string] $DefaultAnswer = "Prefer not to say"
    )
    $prompt = [Spectre.Console.TextPrompt[string]]::new($Question)
    $prompt.DefaultValueStyle = [Spectre.Console.Style]::new($script:DefaultValueColor)
    $prompt = [Spectre.Console.TextPromptExtensions]::DefaultValue($prompt, $DefaultAnswer)
    return Invoke-SpectrePromptAsync -Prompt $prompt
}

function Invoke-SpectreCommandWithStatus {
    <#
    .SYNOPSIS
    Invokes a script block with a Spectre status spinner.

    .DESCRIPTION
    This function starts a Spectre status spinner with the specified title and spinner type, and invokes the specified script block. The spinner will continue to spin until the script block completes.

    .PARAMETER ScriptBlock
    The script block to invoke.

    .PARAMETER Spinner
    The type of spinner to display. Valid values are "dots", "dots2", "dots3", "dots4", "dots5", "dots6", "dots7", "dots8", "dots9", "dots10", "dots11", "dots12", "line", "line2", "pipe", "simpleDots", "simpleDotsScrolling", "star", "star2", "flip", "hamburger", "growVertical", "growHorizontal", "balloon", "balloon2", "noise", "bounce", "boxBounce", "boxBounce2", "triangle", "arc", "circle", "squareCorners", "circleQuarters", "circleHalves", "squish", "toggle", "toggle2", "toggle3", "toggle4", "toggle5", "toggle6", "toggle7", "toggle8", "toggle9", "toggle10", "toggle11", "toggle12", "toggle13", "arrow", "arrow2", "arrow3", "bouncingBar", "bouncingBall", "smiley", "monkey", "hearts", "clock", "earth", "moon", "runner", "pong", "shark", "dqpb", "weather", "christmas", "grenade", "point", "layer", "betaWave", "pulse", "noise2", "gradient", "christmasTree", "santa", "box", "simpleDotsDown", "ballotBox", "checkbox", "radioButton", "spinner", "lineSpinner", "lineSpinner2", "pipeSpinner", "simpleDotsSpinner", "ballSpinner", "balloonSpinner", "noiseSpinner", "bouncingBarSpinner", "smileySpinner", "monkeySpinner", "heartsSpinner", "clockSpinner", "earthSpinner", "moonSpinner", "auto", "random".
    
    .PARAMETER Title
    The title to display above the spinner.

    .PARAMETER Color
    The color of the spinner. Valid values are "black", "red", "green", "yellow", "blue", "magenta", "cyan", "white", "gray", "brightRed", "brightGreen", "brightYellow", "brightBlue", "brightMagenta", "brightCyan", "brightWhite".

    .EXAMPLE
    # Starts a Spectre status spinner with the "dots" spinner type, a yellow color, and the title "Waiting for process to complete". The spinner will continue to spin for 5 seconds.
    Invoke-SpectreCommandWithStatus -ScriptBlock { Start-Sleep -Seconds 5 } -Spinner dots -Title "Waiting for process to complete" -Color yellow
    #>
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithStatus")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,
        # TODO validate spinners
        [string] $Spinner = "Dots",
        [Parameter(Mandatory)]
        [string] $Title,
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )
    [Spectre.Console.AnsiConsole]::Status().Start($Title, {
        param (
            $ctx
        )
        $ctx.Spinner = [Spectre.Console.Spinner+Known]::$Spinner
        $ctx.SpinnerStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
        & $ScriptBlock $ctx
    })
}

function Write-SpectreHost {
    <#
    .SYNOPSIS
    Writes a message to the console using Spectre Console markup.

    .DESCRIPTION
    The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.
    The markup language is defined at [https://spectreconsole.net/markup](https://spectreconsole.net/markup)
    Supported emoji are defined at [https://spectreconsole.net/appendix/emojis](https://spectreconsole.net/appendix/emojis)

    .PARAMETER Message
    The message to write to the console.

    .PARAMETER NoNewline
    If specified, the message will not be followed by a newline character.

    .EXAMPLE
    # This example writes the message "Hello, world!" to the console with the word world flashing blue with an underline followed by an emoji throwing a shaka.
    Write-SpectreHost -Message "Hello, [blue underline rapidblink]world[/]! :call_me_hand:"
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreHost")]
    [Reflection.AssemblyMetadata("description", "The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.")]
    param (
        [Parameter(Mandatory)]
        [string] $Message,
        [switch] $NoNewline
    )

    if($NoNewline) {
        [Spectre.Console.AnsiConsole]::Markup($Message)
    } else {
        [Spectre.Console.AnsiConsole]::MarkupLine($Message)
    }
}

function Invoke-SpectreCommandWithProgress {
    <#
    .SYNOPSIS
    Invokes a Spectre command with a progress bar.

    .DESCRIPTION
    This function takes a script block as a parameter and executes it while displaying a progress bar. The context and task objects are defined at [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/).
    The context requires at least one task to be added for progress to be displayed. The task object is used to update the progress bar by calling the Increment() method or other methods defined in Spectre console [https://spectreconsole.net/api/spectre.console/progresstask/](https://spectreconsole.net/api/spectre.console/progresstask/).

    .PARAMETER ScriptBlock
    The script block to execute.

    .EXAMPLE
    # This example will display a progress bar while the script block is executing.
    Invoke-SpectreCommandWithProgress -ScriptBlock {
        param (
            $Context
        )
        $task1 = $Context.AddTask("Completing a four stage process")
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
    }
    #>
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithProgress")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    [Spectre.Console.AnsiConsole]::Progress().Start({
        param (
            $ctx
        )
        & $ScriptBlock $ctx
    })
}

function Add-SpectreJob {
    <#
    .SYNOPSIS
    Adds a Spectre job to a list of jobs.
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .DESCRIPTION
    This function adds a Spectre job to the list of jobs you want to wait for with Wait-SpectreJobs.

    .PARAMETER Context
    The Spectre context to add the job to. The context object is only available inside Wait-SpectreJobs.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER JobName
    The name of the job to add.

    .PARAMETER Job
    The PowerShell job to add to the context.

    .EXAMPLE
    # This is an example of how to use the Add-SpectreJob function to add two jobs to a jobs list that can be passed to Wait-SpectreJobs.
    Invoke-SpectreCommandWithProgress -Title "Waiting" -ScriptBlock {
        param (
            $Context
        )
        $jobs = @()
        $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 5 })
        $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 10 })
        Wait-SpectreJobs -Context $Context -Jobs $jobs
    }
    #>
    [Reflection.AssemblyMetadata("title", "Add-SpectreJob")]
    param (
        [Parameter(Mandatory)]
        [object] $Context,
        [Parameter(Mandatory)]
        [string] $JobName,
        [Parameter(Mandatory)]
        [System.Management.Automation.Job] $Job
    )

    return @{
        Job = $Job
        Task = $Context.AddTask($JobName)
    }
}

# Adapted from https://key2consulting.com/powershell-how-to-display-job-progress/
function Wait-SpectreJobs {
    <#
    .SYNOPSIS
    Waits for Spectre jobs to complete.
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .DESCRIPTION
    This function waits for Spectre jobs to complete by checking the progress of each job and updating the corresponding task value.

    .PARAMETER Context
    The Spectre progress context object.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER Jobs
    An array of Spectre jobs which are decorated PowerShell jobs.

    .PARAMETER TimeoutSeconds
    The maximum number of seconds to wait for the jobs to complete. Defaults to 60 seconds.

    .EXAMPLE
    # Waits for two jobs to complete
    Invoke-SpectreCommandWithProgress -Title "Waiting" -ScriptBlock {
        param (
            $Context
        )
        $jobs = @()
        $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 5 })
        $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 10 })
        Wait-SpectreJobs -Context $Context -Jobs $jobs
    }
    #>
    [Reflection.AssemblyMetadata("title", "Wait-SpectreJobs")]
    param (
        [Parameter(Mandatory)]
        [object] $Context,
        [Parameter(Mandatory)]
        [array] $Jobs,
        [int] $TimeoutSeconds = 60
    )

    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)

    while(!$Context.IsFinished) {
        if((Get-Date) -gt $timeout) {
            throw "Timed out waiting for jobs after $TimeoutSeconds seconds"
        }
        $completedJobs = 0
        foreach($job in $Jobs) {
            if($job.Job.State -ne "Running") {
                $job.Task.Value = 100.0
                $completedJobs++
                continue
            }
            $progress = 0.0
            if($null -ne $job.Job.ChildJobs[0].Progress) {
                $progress = $job.Job.ChildJobs[0].Progress | Select-Object -Last 1 -ExpandProperty "PercentComplete"
            }
            $job.Task.Value = $progress
        }
        Start-Sleep -Milliseconds 100
    }
}

function Format-SpectreBarChart {
    <#
    .SYNOPSIS
    Formats and displays a bar chart using the Spectre Console module.

    .DESCRIPTION
    This function takes an array of data and displays it as a bar chart using the Spectre Console module. The chart can be customized with a title and width.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the chart. Each object should have a Label, Value, and Color property.

    .PARAMETER Title
    The title to be displayed above the chart.

    .PARAMETER Width
    The width of the chart in characters.

    .EXAMPLE
    # This example displays a bar chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = [Spectre.Console.Color]::Green },
        @{ Label = "Oranges"; Value = 5; Color = [Spectre.Console.Color]::Yellow },
        @{ Label = "Bananas"; Value = 3; Color = [Spectre.Console.Color]::Red }
    )
    Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBarChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        $Title,
        $Width = $Host.UI.RawUI.Width
    )
    begin {
        $barChart = [Spectre.Console.BarChart]::new()
        if($Title) {
            $barChart.Label = $Title
        }
        $barChart.Width = $Width
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $dataItem.Label, $dataItem.Value, $dataItem.Color)
            }
        } else {
            $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $Data.Label, $Data.Value, $Data.Color)
        }
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($barChart)
    }
}

function Get-SpectreEscapedText {
    <#
    .SYNOPSIS
    Escapes text for use in Spectre Console.
    [ShaunLawrie/PwshSpectreConsole/issues/5](https://github.com/ShaunLawrie/PwshSpectreConsole/issues/5)

    .DESCRIPTION
    This function escapes text for use where Spectre Console accepts markup. It is intended to be used as a helper function for other functions that output text to the console using Spectre Console which contains special characters that need escaping.
    See [https://spectreconsole.net/markup](https://spectreconsole.net/markup) for more information about the markup language used in Spectre Console.

    .PARAMETER Text
    The text to be escaped.

    .EXAMPLE
    # This example shows some data that requires escaping being embedded in a string passed to Format-SpectrePanel.
    $data = "][[][]]][[][][]["
    Format-SpectrePanel -Title "Unescaped data" -Data "I want escaped $($data | Get-SpectreEscapedText) [yellow]and[/] [red]unescaped[/] data"
    #>
    [Reflection.AssemblyMetadata("title", "Get-SpectreEscapedText")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Text
    )
    return [Spectre.Console.Markup]::Escape($Text)
}

function Format-SpectreBreakdownChart {
    <#
    .SYNOPSIS
    Formats data into a breakdown chart.

    .DESCRIPTION
    This function takes an array of data and formats it into a breakdown chart using Spectre.Console.BreakdownChart. The chart can be customized with a specified width and color.

    .PARAMETER Data
    An array of data to be formatted into a breakdown chart.

    .PARAMETER Width
    The width of the chart. Defaults to the width of the console.

    .EXAMPLE
    # This example displays a breakdown chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = [Spectre.Console.Color]::Red },
        @{ Label = "Oranges"; Value = 20; Color = [Spectre.Console.Color]::Orange1 },
        @{ Label = "Bananas"; Value = 15; Color = [Spectre.Console.Color]::Yellow }
    )
    Format-SpectreBreakdownChart -Data $data -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBreakdownChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        $Width = $Host.UI.RawUI.Width
    )
    begin {
        $chart = [Spectre.Console.BreakdownChart]::new()
        $chart.Width = $Width
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $dataItem.Label, $dataItem.Value, $dataItem.Color) | Out-Null
            }
        } else {
            [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $Data.Label, $Data.Value, $Data.Color) | Out-Null
        }
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($chart)
    }
}

function Format-SpectrePanel {
    <#
    .SYNOPSIS
    Formats a string as a Spectre Console panel with optional title, border, and color.

    .DESCRIPTION
    This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.

    .PARAMETER Data
    The string to be formatted as a panel.

    .PARAMETER Title
    The title to be displayed at the top of the panel.

    .PARAMETER Border
    The type of border to be displayed around the panel. Valid values are "Rounded", "Heavy", "Double", "Single", "None".

    .PARAMETER Expand
    Switch parameter that specifies whether the panel should be expanded to fill the available space.

    .PARAMETER Color
    The color of the panel border.

    .EXAMPLE
    # This example displays a panel with the title "My Panel", a rounded border, and a red border color.
    Format-SpectrePanel -Data "Hello, world!" -Title "My Panel" -Border "Rounded" -Color "Red"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePanel")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Data,
        [string] $Title,
        [string] $Border = "Rounded",
        [switch] $Expand, 
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )
    $panel = [Spectre.Console.Panel]::new($Data)
    if($Title) {
        $panel.Header = [Spectre.Console.PanelHeader]::new($Title)
    }
    $panel.Expand = $Expand
    $panel.Border = [Spectre.Console.BoxBorder]::$Border
    $panel.BorderStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
    [Spectre.Console.AnsiConsole]::Write($panel)
}

function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table.
    
    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.
    
    .PARAMETER Data
    The array of objects to be formatted into a table.
    
    .PARAMETER Border
    The border style of the table. Default is "Double".
    
    .PARAMETER Color
    The color of the table border. Default is the accent color of the script.
    
    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{Name="John"; Age=25; City="New York"},
        [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
    )
    Format-SpectreTable -Data $data
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTable")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [string] $Border = "Double",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )
    begin {
        $table = [Spectre.Console.Table]::new()
        $table.Border = [Spectre.Console.TableBorder]::$Border
        $table.BorderStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
        $headerProcessed = $false
    }
    process {
        if(!$headerProcessed) {
            $Data[0].psobject.Properties.Name | Foreach-Object {
                $table.AddColumn($_) | Out-Null
            }
            
            $headerProcessed = $true
        }
        $Data | Foreach-Object {
            $row = @()
            $_.psobject.Properties | ForEach-Object {
                $cell = $_.Value
                if ($null -eq $cell) {
                    $row += [Spectre.Console.Text]::new("")
                }
                else {
                    $row += [Spectre.Console.Text]::new($cell.ToString())
                }
            }
            $table = [Spectre.Console.TableExtensions]::AddRow($table, [Spectre.Console.Text[]]$row)
        }
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($table)
    }
}

function Format-SpectreTree {
    <#
    .SYNOPSIS
    Formats a hashtable as a tree using Spectre Console.

    .DESCRIPTION
    This function takes a hashtable and formats it as a tree using Spectre Console. The hashtable should have a 'Label' key and a 'Children' key. The 'Label' key should contain the label for the root node of the tree, and the 'Children' key should contain an array of hashtables representing the child nodes of the root node. Each child hashtable should have a 'Label' key and a 'Children' key, following the same structure as the root node.

    .PARAMETER Data
    The hashtable to format as a tree.

    .PARAMETER Border
    The type of border to use for the tree. Valid values are 'Rounded', 'Heavy', 'Light', 'Double', 'Solid', 'Ascii', and 'None'. Default is 'Rounded'.

    .PARAMETER Color
    The color to use for the tree. This can be a Spectre Console color name or a hex color code. Default is the accent color defined in the script.

    .EXAMPLE
    # This example formats a hashtable as a tree with a heavy border and green color.
    $data = @{
        Label = "Root"
        Children = @(
            @{
                Label = "Child 1"
                Children = @(
                    @{
                        Label = "Grandchild 1"
                        Children = @()
                    },
                    @{
                        Label = "Grandchild 2"
                        Children = @()
                    }
                )
            },
            @{
                Label = "Child 2"
                Children = @()
            }
        )
    }

    Format-SpectreTree -Data $data -Border "Heavy" -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTree")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $Data,
        [string] $Border = "Rounded",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToString()
    )

    function Add-SpectreTreeNode {
        param (
            $Node,
            $Children
        )
    
        foreach($child in $Children) {
            $newNode = [Spectre.Console.HasTreeNodeExtensions]::AddNode($Node, $child.Label)
            if($child.Children.Count -gt 0) {
                Add-SpectreTreeNode -Node $newNode -Children $child.Children
            }
        }
    }

    $tree = [Spectre.Console.Tree]::new($Data.Label)

    Add-SpectreTreeNode -Node $tree -Children $Data.Children

    $tree.Style = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
    [Spectre.Console.AnsiConsole]::Write($tree)
}

function Read-SpectrePause {
    <#
    .SYNOPSIS
    Pauses the script execution and waits for user input to continue.

    .DESCRIPTION
    The Read-SpectrePause function pauses the script execution and waits for user input to continue. It displays a message prompting the user to press the enter key to continue. If the end of the console window is reached, the function clears the message and moves the cursor up to the previous line.

    .PARAMETER Message
    The message to display to the user. The default message is "[<default value color>]Press [<accent color]<enter>[/] to continue[/]".

    .PARAMETER NoNewline
    Indicates whether to write a newline character before displaying the message. By default, a newline character is written.

    .EXAMPLE
    # This example pauses the script execution and displays the message "Press any key to continue...". The function waits for the user to press a key before continuing.
    Read-SpectrePause -Message "Press any key to continue..."
    #>
    [Reflection.AssemblyMetadata("title", "Read-SpectrePause")]
    param (
        [string] $Message = "[$script:DefaultValueColor]Press [$script:AccentColor]<enter>[/] to continue[/]",
        [switch] $NoNewline
    )

    $position = $Host.UI.RawUI.CursorPosition
    if(!$NoNewline) {
        Write-Host ""
    }
    Write-SpectreHost $Message -NoNewline
    Read-Host
    $endPosition = $Host.UI.RawUI.CursorPosition
    if($endPosition -eq $position) {
        # Reached the end of the window
        [Console]::SetCursorPosition($position.X, $position.Y - 2)
        Write-Host (" " * $Message.Length)
        [Console]::SetCursorPosition($position.X, $position.Y - 2)
    } else {
        [Console]::SetCursorPosition($position.X, $position.Y)
        Write-Host (" " * $Message.Length)
        [Console]::SetCursorPosition($position.X, $position.Y)
    }
}