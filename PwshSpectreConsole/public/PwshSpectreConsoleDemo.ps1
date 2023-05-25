using module "..\private\Attributes.psm1"

function Start-SpectreDemo {
    Clear-Host

    function Write-SpectreExample {
        param (
            [Parameter(ValueFromPipeline)]
            [string] $Codeblock,
            [string] $Title,
            [string] $Description,
            [switch] $HideHeader,
            [switch] $NoNewline
        )
        if($host.UI.RawUI.WindowSize.Width -lt 120) {
            Write-SpectreFigletText "Pwsh + Spectre!"
        } else {
            Write-SpectreFigletText "Welcome to PwshSpectreConsole!"
        }
        Write-Host ""

        Write-SpectreRule $Title -Color ([Spectre.Console.Color]::SteelBlue1)
        Write-SpectreParagraph $Description
        if(!$HideHeader) {
            Write-CodeblockHeader
        }
        $Codeblock | Write-Codeblock -SyntaxHighlight -ShowLineNumbers
        if(!$NoNewline) {
            Write-Host ""
        }
    }

    if($host.UI.RawUI.WindowSize.Width -lt 120) {
        Write-SpectreFigletText "Pwsh + Spectre!"
    } else {
        Write-SpectreFigletText "Welcome to PwshSpectreConsole!"
    }
    Write-Host ""

    Write-SpectreRule "PwshSpectreConsole Intro" -Color ([Spectre.Console.Color]::SteelBlue1)
    Write-SpectreParagraph "PwshSpectreConsole is an opinionated wrapper for the awesome Spectre.Console library. It's opinionated in that I have not just exposed the internals of Spectre Console to PowerShell but have wrapped them in a way that makes them work better in the PowerShell ecosystem (in my opinion 😜)."
    Write-SpectreParagraph "Spectre Console is mostly an async library and it leans heavily on types and extension methods in C# which are very verbose to work with in PowerShell so this module hides away some of the complexity."
    Write-SpectreParagraph "The module doesn't expose the full feature set of Spectre.Console because the scope of the library is huge and I've focused on the features that I use to enhance my scripts."
    Write-Host ""
    if(![Spectre.Console.AnsiConsole]::Console.Profile.Capabilities.Unicode) {
        Write-Warning "To enable all features of Spectre.Console you need to enable Unicode support in your PowerShell profile by adding the following to your profile at $PROFILE. See https://spectreconsole.net/best-practices for more info.`n`n`$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding"
    }

    Read-SpectrePause -NoNewline
    Clear-Host

    $example = @'
$name = Read-SpectreText "What's your [blue]name[/]?"
'@
    $example | Write-SpectreExample -Title "Text Entry" -Description "Text entry is essential for user input and interaction in a terminal application. It allows users to enter commands, input data, or provide search queries, giving them the ability to interact with the application and perform tasks. The built-in PowerShell Read-Host has some additional functionality like auto-complete and history that the Spectre text entry doesn't have so Read-Host is usually a better option for text entry in your scripts."
    $example | Invoke-Expression
    Clear-Host

    $example = @'
$choices = @("Sushi", "Tacos", "Pad Thai", "Lobster", "Falafel", "Chicken Parmesan", "Ramen", "Fish and Chips", "Biryani", "Croissants", "Enchiladas", "Shepherd's Pie", "Gyoza", "Fajitas", "Samosas", "Bruschetta", "Paella", "Hamburger", "Poutine", "Ceviche")

$food = Read-SpectreSelection `
            -Title "What's your favourite [blue]food[/]?" `
            -Choices $choices
'@
    $example | Write-SpectreExample -Title "Select Lists" -Description "Select lists are helpful for presenting multiple options to the user in an organized manner. They enable users to choose one option from a list, simplifying decision-making and input tasks and reducing the chances of errors. The list will also paginate if there are too many options to show all at once."
    $example | Invoke-Expression
    Clear-Host

    $example = @'
$choices = @(
    @{ Name = "RGB"; Choices = @("red", "green", "blue") },
    @{ Name = "CMYK"; Choices = @("cyan", "magenta", "yellow", "black") }
)

$colors = Read-SpectreMultiSelectionGrouped `
              -Title "What's your favourite [blue]color[/]?" `
              -Choices $choices
'@
    $example | Write-SpectreExample -Title "Multi-Select Lists" -Description "Multi-select lists allow users to choose multiple options from a list. This feature is useful when users need to perform operations on multiple items at once, such as selecting multiple files to delete or copy. The multi-select lists also allow categorizing items so you can select the whole category at once."
    $example | Invoke-Expression
    Clear-Host

    $example = @'
$message = "Hi $name, nice to meet you :waving_hand:`n"
$message += "Your favourite food is $food :fork_and_knife:`n"
$message += "And your favourite colors are:`n"
foreach($color in $colors) {
    $message += " - [$color]$color[/]`n"
}
$message += "Nice! :rainbow:"

$message | Format-SpectrePanel -Title "Output"
'@
    $example | Write-SpectreExample -Title "Panels" -Description "Panels are used to separate and organize different sections or groups of information within a terminal application. They help keep the interface clean and structured, making it easier for users to navigate and understand the application."
    Invoke-Expression $example

    Read-SpectrePause
    Clear-Host

    $example = @'
Get-Process | Select-Object -First 10 -Property Id, Name, Handles | Format-SpectreTable
'@
    $example | Write-SpectreExample -Title "Tables" -Description "Tables are an effective way to display structured data in a terminal application. They provide a clear and organized representation of data, making it easier for users to understand, compare, and analyze the information. The tables in Spectre Console are not as feature rich as the built-in PowerShell Format-Table but they can have more visual impact."
    Invoke-Expression $example

    Read-SpectrePause
    Clear-Host

    $example = @'
@{
    Label = "Root"
    Children = @(
        @{
            Label = "First Child"
            Children = @(
                @{ Label = "With"; Children = @() },
                @{ Label = "Loads"; Children = @() },
                @{ Label = "More"; Children = @() },
                @{ Label = "Nested"; Children = @( @{ Label = "Children"; Children = @() } ) }
            )
        },
        @{ Label = "Second Child"; Children = @() }
    )
} | Format-SpectreTree
'@
    $example | Write-SpectreExample -Title "Tree Diagrams" -Description "Tree diagrams help visualize hierarchical relationships between different elements in a dataset. They are particularly useful in applications dealing with file systems, organizational structures, or nested data, providing an intuitive representation of the structure."
    Invoke-Expression $example

    Read-SpectrePause
    Clear-Host

    $example = @'
$(
    @{
        Label = "Apple"
        Value = 12
        Color = [Spectre.Console.Color]::Green
    },
    @{
        Label = "Orange"
        Value = 54
        Color = [Spectre.Console.Color]::Orange1
    },
    @{
        Label = "Strawberry"
        Value = 51
        Color = [Spectre.Console.Color]::Red
    },
    @{
        Label = "Banana"
        Value = 33
        Color = [Spectre.Console.Color]::Yellow
    }
) | Format-SpectreBarChart
'@
    $example | Write-SpectreExample -Title "Bar Charts" -Description "Bar charts are a powerful way to visualize data comparisons in a terminal application. They can represent various data types, such as categorical or numerical data, making it easier for users to identify trends, patterns, and differences between data points."
    Invoke-Expression $example

    Read-SpectrePause
    Clear-Host

    $example = @'
$(
    @{
        Label = "Apple"
        Value = 12
        Color = [Spectre.Console.Color]::Green
    },
    @{
        Label = "Strawberry"
        Value = 15
        Color = [Spectre.Console.Color]::Red
    },
    @{
        Label = "Orange"
        Value = 54
        Color = [Spectre.Console.Color]::Orange1
    },
    @{
        Label = "Plum"
        Value = 75
        Color = [Spectre.Console.Color]::Fuchsia
    }
) | Format-SpectreBreakdownChart
'@
    $example | Write-SpectreExample -Title "Breakdown Charts" -Description "Like a pie chart but horizontal, breakdown charts can be used to show the proportions of a total that components make up."
    Invoke-Expression $example
    Read-SpectrePause
    Clear-Host

    $example = @'
Invoke-SpectreCommandWithStatus -Spinner "Dots2" -Title "Showing a spinner..." -ScriptBlock {
    # Write updates tot the host using Write-SpectreHost
    Start-Sleep -Seconds 1
    Write-SpectreHost "[grey]LOG:[/] Doing some work"
    Start-Sleep -Seconds 1
    Write-SpectreHost "[grey]LOG:[/] Doing some more work"
    Start-Sleep -Seconds 1
    Write-SpectreHost "[grey]LOG:[/] Done"
    Start-Sleep -Seconds 1
}
'@
    $example | Write-SpectreExample -Title "Progress Spinners" -Description "Progress spinners provide visual feedback to users when an operation or task is in progress. They help indicate that the application is working on a request, preventing users from becoming frustrated or assuming the application has stalled."
    Invoke-Expression $example

    Read-SpectrePause -NoNewline
    Clear-Host

    $example = @'
Invoke-SpectreCommandWithProgress -ScriptBlock {
    param (
        $ctx
    )
    $task1 = $ctx.AddTask("Completing a four stage process")
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
'@
    $example | Write-SpectreExample -NoNewline -Title "Progress Bars" -Description "Progress bars give users a visual indication of the progress of a specific task or operation. They show the percentage of completion, helping users understand how much work remains and providing a sense of time estimation for the task."
    Invoke-Expression $example

    Read-SpectrePause -NoNewline
    Clear-Host

    $example = @'
Invoke-SpectreCommandWithProgress -ScriptBlock {
    param ( $ctx )

    $jobs = @()
    $jobs += Add-SpectreJob -Context $ctx -JobName "Drawing a picture" -Job (
        Start-Job {
            $progress = 0
            while($progress -lt 100) {
                $progress += 1.5
                Write-Progress -Activity "Processing" -PercentComplete $progress
                Start-Sleep -Milliseconds 50
            }
        }
    )
    $jobs += Add-SpectreJob -Context $ctx -JobName "Driving a car" -Job (
        Start-Job {
            $progress = 0
            while($progress -lt 100) {
                $progress += 0.9
                Write-Progress -Activity "Processing" -PercentComplete $progress
                Start-Sleep -Milliseconds 50
            }
        }
    )

    Wait-SpectreJobs -Context $ctx -Jobs $jobs
}
'@
    $example | Write-SpectreExample -NoNewline -Title "Parallel Progress Bars" -Description "Parallel progress bars are used to display the progress of multiple tasks or operations simultaneously. They are useful in applications that perform several tasks concurrently, allowing users to monitor the status of each task individually."
    Invoke-Expression $example

    Read-SpectrePause -NoNewline
    Clear-Host

    $example = @'
Invoke-SpectreCommandWithProgress -ScriptBlock {
    param (
        $ctx
    )
    $task1 = $ctx.AddTask("Doing something")
    $task1.IsIndeterminate = $true
    Start-Sleep -Seconds 10
    $task1.IsIndeterminate = $false
    $task1.Value = 100
    $task1.StopTask()
}
'@
    $example | Write-SpectreExample -NoNewline -Title "Indeterminate Progress Bars" -Description "Indeterminate progress bars are used when the duration of a task or operation is unknown or cannot be accurately estimated. They provide a visual indication that work is being done, even if the exact progress cannot be determined, reassuring users that the application is still functioning. You could also use spinners to portray this information but sometimes you want to be consistent if you're already using progress bars for other tasks."
    Invoke-Expression $example

    Read-SpectrePause -NoNewline
    Clear-Host

    $example = @"
Get-SpectreImage "$PSScriptRoot\..\private\hero.png"
"@
    $example | Write-SpectreExample -Title "View Images" -Description "Images can be rendered in the terminal, given a path to an image Spectre Console will downsample the image to a resolution that will fit within the terminal width or you can choose your own width setting."
    Invoke-Expression $example

    Read-SpectrePause
    Write-Host ""
}