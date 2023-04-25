$script:AccentColor = [Spectre.Console.Color]::Blue
$script:DefaultValueColor = [Spectre.Console.Color]::Grey

$script:Colors = @("Aqua", "Aquamarine1", "Aquamarine1_1", "Aquamarine3", "Black", "Blue", "Blue1", "Blue3", "Blue3_1", "BlueViolet", "CadetBlue", "CadetBlue_1", "Chartreuse1", "Chartreuse2", "Chartreuse2_1", "Chartreuse3", "Chartreuse3_1", "Chartreuse4", "CornflowerBlue", "Cornsilk1", "Cyan1", "Cyan2", "Cyan3", "DarkBlue", "DarkCyan", "DarkGoldenrod", "DarkGreen", "DarkKhaki", "DarkMagenta", "DarkMagenta_1", "DarkOliveGreen1", "DarkOliveGreen1_1", "DarkOliveGreen2", "DarkOliveGreen3", "DarkOliveGreen3_1", "DarkOliveGreen3_2", "DarkOrange", "DarkOrange3", "DarkOrange3_1", "DarkRed", "DarkRed_1", "DarkSeaGreen", "DarkSeaGreen1", "DarkSeaGreen1_1", "DarkSeaGreen2", "DarkSeaGreen2_1", "DarkSeaGreen3", "DarkSeaGreen3_1", "DarkSeaGreen4", "DarkSeaGreen4_1", "DarkSlateGray1", "DarkSlateGray2", "DarkSlateGray3", "DarkTurquoise", "DarkViolet", "DarkViolet_1", "DeepPink1", "DeepPink1_1", "DeepPink2", "DeepPink3", "DeepPink3_1", "DeepPink4", "DeepPink4_1", "DeepPink4_2", "DeepSkyBlue1", "DeepSkyBlue2", "DeepSkyBlue3", "DeepSkyBlue3_1", "DeepSkyBlue4", "DeepSkyBlue4_1", "DeepSkyBlue4_2", "Default", "DodgerBlue1", "DodgerBlue2", "DodgerBlue3", "Fuchsia", "Gold1", "Gold3", "Gold3_1", "Green", "Green1", "Green3", "Green3_1", "Green4", "GreenYellow", "Grey", "Grey0", "Grey100", "Grey11", "Grey15", "Grey19", "Grey23", "Grey27", "Grey3", "Grey30", "Grey35", "Grey37", "Grey39", "Grey42", "Grey46", "Grey50", "Grey53", "Grey54", "Grey58", "Grey62", "Grey63", "Grey66", "Grey69", "Grey7", "Grey70", "Grey74", "Grey78", "Grey82", "Grey84", "Grey85", "Grey89", "Grey93", "Honeydew2", "HotPink", "HotPink2", "HotPink3", "HotPink3_1", "HotPink_1", "IndianRed", "IndianRed1", "IndianRed1_1", "IndianRed_1", "Khaki1", "Khaki3", "LightCoral", "LightCyan1", "LightCyan3", "LightGoldenrod1", "LightGoldenrod2", "LightGoldenrod2_1", "LightGoldenrod2_2", "LightGoldenrod3", "LightGreen", "LightGreen_1", "LightPink1", "LightPink3", "LightPink4", "LightSalmon1", "LightSalmon3", "LightSalmon3_1", "LightSeaGreen", "LightSkyBlue1", "LightSkyBlue3", "LightSkyBlue3_1", "LightSlateBlue", "LightSlateGrey", "LightSteelBlue", "LightSteelBlue1", "LightSteelBlue3", "LightYellow3", "Lime", "Magenta1", "Magenta2", "Magenta2_1", "Magenta3", "Magenta3_1", "Magenta3_2", "Maroon", "MediumOrchid", "MediumOrchid1", "MediumOrchid1_1", "MediumOrchid3", "MediumPurple", "MediumPurple1", "MediumPurple2", "MediumPurple2_1", "MediumPurple3", "MediumPurple3_1", "MediumPurple4", "MediumSpringGreen", "MediumTurquoise", "MediumVioletRed", "MistyRose1", "MistyRose3", "NavajoWhite1", "NavajoWhite3", "Navy", "NavyBlue", "Olive", "Orange1", "Orange3", "Orange4", "Orange4_1", "OrangeRed1", "Orchid", "Orchid1", "Orchid2", "PaleGreen1", "PaleGreen1_1", "PaleGreen3", "PaleGreen3_1", "PaleTurquoise1", "PaleTurquoise4", "PaleVioletRed1", "Pink1", "Pink3", "Plum1", "Plum2", "Plum3", "Plum4", "Purple", "Purple3", "Purple4", "Purple4_1", "Purple_1", "Purple_2", "Red", "Red1", "Red3", "Red3_1", "RosyBrown", "RoyalBlue1", "Salmon1", "SandyBrown", "SeaGreen1", "SeaGreen1_1", "SeaGreen2", "SeaGreen3", "Silver", "SkyBlue1", "SkyBlue2", "SkyBlue3", "SlateBlue1", "SlateBlue3", "SlateBlue3_1", "SpringGreen1", "SpringGreen2", "SpringGreen2_1", "SpringGreen3", "SpringGreen3_1", "SpringGreen4", "SteelBlue", "SteelBlue1", "SteelBlue1_1", "SteelBlue3", "Tan", "Teal", "Thistle1", "Thistle3", "Turquoise2", "Turquoise4", "Violet", "Wheat1", "Wheat4", "White", "Yellow", "Yellow1", "Yellow2", "Yellow3", "Yellow3_1", "Yellow4", "Yellow4_1")

function Invoke-SpectrePromptAsync {
    param (
        $Prompt
    )
    $cts = [System.Threading.CancellationTokenSource]::new()
    try {
        $task = $Prompt.ShowAsync([Spectre.Console.AnsiConsole]::Console, $cts.Token)
        while (-not $task.AsyncWaitHandle.WaitOne(200)) { <# Waiting for async task while allowing ctrl-c interrupts #> }
        return $task.GetAwaiter().GetResult()
    } finally {
        $cts.Cancel()
        $task.Dispose()
    }
}

function Set-SpectreColors {
    param (
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
        [string] $AccentColor = "Blue",
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
        [string] $DefaultValueColor = "Grey"
    )
    $script:AccentColor = [Spectre.Console.Color]::$AccentColor
    $script:DefaultValueColor = [Spectre.Console.Color]::$DefaultValueColor
}

function Write-SpectreParagraph {
    param (
        [string] $Text = "This is a sample paragraph! Provide some text to the command to write your own. This function writes a body of text without splitting a word across multiple lines."
    )
    $windowWidth = $Host.UI.RawUI.WindowSize.Width - 1
    $textWithLineBreaks = (Select-String -Input $Text -Pattern ".{1,$windowWidth}(\s|$)" -AllMatches).Matches.Value
    $textWithLineBreaks | Foreach-Object {
        Write-Host $_
    }
}

function Write-SpectreRule {
    param (
        [string] $Title,
        [string] $Alignment = "Left",
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
        [string] $Color = $script:AccentColor.ToString()
    )
    $rule = [Spectre.Console.Rule]::new("[$($Color)]$Title[/]")
    $rule.Justification = [Spectre.Console.Justify]::$Alignment
    [Spectre.Console.AnsiConsole]::Write($rule)
}

function Write-SpectreFigletText {
    param (
        [string] $Text = "Hello Spectre!",
        [string] $Alignment = "Left",
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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

function Read-SpectreSelection {
    param (
        [string] $Title = "What's your favourite colour [$($script:AccentColor.ToString())]option[/]?",
        [array] $Choices = @("red", "green", "blue"),
        [string] $ChoiceLabelProperty,
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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
    param (
        [string] $Title = "What are your favourite [$($script:AccentColor.ToString())]colors[/]?",
        [array] $Choices = @("red", "orange", "yellow", "green", "blue", "indigo", "violet"),
        [string] $ChoiceLabelProperty,
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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
    param (
        [scriptblock] $ScriptBlock,
        [string] $Spinner,
        [string] $Title,
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
        [string] $Color = $script:AccentColor.ToString()
    )
    [Spectre.Console.AnsiConsole]::Status().Start($Title, {
        param (
            $ctx
        )
        $ctx.Spinner = [Spectre.Console.Spinner+Known]::$Spinner
        $ctx.SpinnerStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::$Color)
        & $ScriptBlock
    })
}

function Write-SpectreHost {
    param (
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
    param (
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
    param (
        [object] $Context,
        [string] $JobName,
        [System.Management.Automation.Job] $Job
    )

    return @{
        Job = $Job
        Task = $Context.AddTask($JobName)
    }
}

# Adapted from https://key2consulting.com/powershell-how-to-display-job-progress/
function Wait-SpectreJobs {
    param (
        [object] $Context,
        [array] $Jobs,
        [int] $TimeoutSeconds = 60
    )

    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)

    while(!$Context.IsFinished) {
        if((Get-Date) -gt $timeout) {
            throw "Timed out waiting for jobs after $TimeoutSeconds seconds"
        }
        foreach($job in $Jobs) {
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
    param (
        [Parameter(ValueFromPipeline)]
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
        $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $Data.Label, $Data.Value, $Data.Color)
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($barChart)
    }
}

function Format-SpectreBreakdownChart {
    param (
        [Parameter(ValueFromPipeline)]
        [array] $Data,
        $Width = $Host.UI.RawUI.Width
    )
    begin {
        $chart = [Spectre.Console.BreakdownChart]::new()
        $chart.Width = $Width
    }
    process {
        $chart = [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $Data.Label, $Data.Value, $Data.Color)
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($chart)
    }
}

function Format-SpectrePanel {
    param (
        [Parameter(ValueFromPipeline)]
        [string] $Data,
        [string] $Title,
        [string] $Border = "Rounded",
        [switch] $Expand, 
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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
    # TODO fix this to be not crap and use a formatter or something
    param (
        [Parameter(ValueFromPipeline)]
        [array] $Data,
        [string] $Border = "Double",
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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
            $Data | Get-Member -MemberType Properties | Foreach-Object {
                $table.AddColumn($_.Name) | Out-Null
            }
            $headerProcessed = $true
        }
        $row = @()
        $Data | Get-Member -MemberType Properties | Foreach-Object {
            if($null -eq $Data."$($_.Name)") {
                $row += [Spectre.Console.Text]::new("")
            } else {
                $row += [Spectre.Console.Text]::new($Data."$($_.Name)".ToString())
            }
        }
        $table = [Spectre.Console.TableExtensions]::AddRow($table, [Spectre.Console.Text[]]$row)
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($table)
    }
}

function Format-SpectreTree {
    param (
        [Parameter(ValueFromPipeline)]
        [hashtable] $Data,
        [string] $Border = "Rounded",
        [ValidateScript({if($script:Colors -contains $_) { $true } else { throw "Color must be one of $($script:Colors -join ', ')" } })]
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