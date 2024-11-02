<#
.SYNOPSIS
Invokes a script block with live rendering.

.DESCRIPTION
Starts live rendering for a given renderable. The script block is able to update the renderable in real-time and Spectre Console redraws every time the scriptblock calls `$Context.refresh()`.  
See https://spectreconsole.net/live/live-display for more information.

.PARAMETER Data
The renderable object to render.

.PARAMETER ScriptBlock
The script block to execute while the live renderable is being rendered.

.EXAMPLE
# **Example 1**  
# This is a live updating table example, the table will be updated every second with a new row.
$data = @(
    [pscustomobject]@{Name="John"; Age=25; City="New York"},
    [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
)
$table = Format-SpectreTable -Data $data

Invoke-SpectreLive -Data $table -ScriptBlock {
    param (
        [Spectre.Console.LiveDisplayContext] $Context
    )
    $Context.refresh()
    for ($i = 0; $i -lt 5; $i++) {
        Start-Sleep -Seconds 1
        $table = Add-SpectreTableRow -Table $table -Columns "Shaun $i", $i, "Wellington"
        $Context.refresh()
    }
}

.EXAMPLE
# **Example 2**  
# This is a complex live updating nested layout example. It demonstrates how to create a file browser with a preview panel.
# The root layout is constructed with a header and a content panel. The content panel is split into two columns: filelist and preview.
# Invoke-SpectreLive is used to render the layout and update the content of each panel on every loop iteration until the escape key is pressed.
$layout = New-SpectreLayout -Name "root" -Rows @(
    # Row 1
    (
        New-SpectreLayout -Name "header" -MinimumSize 5 -Ratio 1 -Data ("empty")
    ),
    # Row 2
    (
        New-SpectreLayout -Name "content" -Ratio 10 -Columns @(
            (
                New-SpectreLayout -Name "filelist" -Ratio 2 -Data "empty"
            ),
            (
                New-SpectreLayout -Name "preview" -Ratio 4 -Data "empty"
            )
        )
    )
)

# Functions for rendering the content of each panel
function Get-TitlePanel {
    return "File Browser - Spectre Live Demo [gray]$(Get-Date)[/]" | Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle | Format-SpectrePanel -Expand
}

function Get-FileListPanel {
    param (
        $Files,
        $SelectedFile
    )
    $fileList = $Files | ForEach-Object {
        $name = $_.Name
        if ($_.Name -eq $SelectedFile.Name) {
            $name = "[Turquoise2]$($name)[/]"
        }
        return $name
    } | Out-String
    return Format-SpectrePanel -Header "[white]File List[/]" -Data $fileList.Trim() -Expand
}

function Get-PreviewPanel {
    param (
        $SelectedFile
    )
    $item = Get-Item -Path $SelectedFile.FullName
    $result = ""
    if ($item -is [System.IO.DirectoryInfo]) {
        $result = "[grey]$($SelectedFile.Name) is a directory.[/]"
    } elseif ($item.Name -match "\.(jpg|jpeg|png|gif)$") {
        $result = Get-SpectreSixelImage $item.FullName
    } else {
        try {
            $content = Get-Content -Path $item.FullName -Raw -ErrorAction Stop
            $result = "[grey]$($content | Get-SpectreEscapedText)[/]"
        } catch {
            $result = "[red]Error reading file content: $($_.Exception.Message | Get-SpectreEscapedText)[/]"
        }
    }
    return $result | Format-SpectrePanel -Header "[white]Preview[/]" -Expand
}

function Get-LastKeyPressed {
    $lastKeyPressed = $null
    while ([Console]::KeyAvailable) {
        $lastKeyPressed = [Console]::ReadKey($true)
    }
    return $lastKeyPressed
}

# Start live rendering the layout
# Type "↓", "↓", "↓" to navigate the file list, and press "Enter" to open a file in Notepad
Invoke-SpectreLive -Data $layout -ScriptBlock {
    param (
        [Spectre.Console.LiveDisplayContext] $Context
    )

    # State
    $fileList = @(@{Name = ".."; Fullname = ".."}) + (Get-ChildItem)
    $selectedFile = $fileList[0]

    while ($true) {
        # Handle input
        $lastKeyPressed = Get-LastKeyPressed
        if ($lastKeyPressed -ne $null) {
            if ($lastKeyPressed.Key -eq "DownArrow") {
                $selectedFile = $fileList[($fileList.IndexOf($selectedFile) + 1) % $fileList.Count]
            } elseif ($lastKeyPressed.Key -eq "UpArrow") {
                $selectedFile = $fileList[($fileList.IndexOf($selectedFile) - 1 + $fileList.Count) % $fileList.Count]
            } elseif ($lastKeyPressed.Key -eq "Enter") {
                if ($selectedFile -is [System.IO.DirectoryInfo] -or $selectedFile.Name -eq "..") {
                    $fileList = @(@{Name = ".."; Fullname = ".."}) + (Get-ChildItem -Path $selectedFile.FullName)
                    $selectedFile = $fileList[0]
                } else {
                    notepad $selectedFile.FullName
                    return
                }
            } elseif ($lastKeyPressed.Key -eq "Escape") {
                return
            }
        }

        # Generate new data
        $titlePanel = Get-TitlePanel
        $fileListPanel = Get-FileListPanel -Files $fileList -SelectedFile $selectedFile
        $previewPanel = Get-PreviewPanel -SelectedFile $selectedFile

        # Update layout
        $layout["header"].Update($titlePanel) | Out-Null
        $layout["filelist"].Update($fileListPanel) | Out-Null
        $layout["preview"].Update($previewPanel) | Out-Null

        # Draw changes
        $Context.Refresh()
        Start-Sleep -Milliseconds 200
    }
}

.EXAMPLE
# **Example 3**  
# This is a simple example of creating a chat application. In this example a different approach is used to render the components, each component has been passed a copy of the context and layout object so it can update itself.

Set-SpectreColors -AccentColor DeepPink1

# Build root layout scaffolding for:
# +--------------------------------+
# |             Title              | <- Update-TitleComponent will render the title
# |--------------------------------|
# |                                | <- Update-MessageListComponent will display the list of messages here
# |                                |
# |            Messages            |
# |                                |
# |                                |
# |--------------------------------|
# |        CustomTextEntry         | <- Update-CustomTextEntryComponent will create a text entry prompt here that is manually managed by pushing keys into a string
# |________________________________|

$layout = New-SpectreLayout -Name "root" -Rows @(
    # Row 1
    (New-SpectreLayout -Name "title" -MinimumSize 5 -Ratio 1 -Data ("empty")),
    # Row 2
    (New-SpectreLayout -Name "messages" -Ratio 10 -Data ("empty")),
    # Row 3
    (New-SpectreLayout -Name "customTextEntry" -MinimumSize 5 -Ratio 1 -Data ("empty"))
)

# Component functions for rendering the content of each panel
function Update-TitleComponent {
    param (
        [Spectre.Console.LiveDisplayContext] $Context,
        [Spectre.Console.Layout] $LayoutComponent
    )
    $component = @(
        ("🧠 ChaTTY" | Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle | Format-SpectrePadded -Padding 1),
        (Write-SpectreRule -LineColor DeepPink1 -PassThru)
    ) | Format-SpectreRows | Format-SpectrePanel -Border None
    $LayoutComponent.Update($component) | Out-Null
    $Context.Refresh()
}

function Update-MessageListComponent {
    param (
        [Spectre.Console.LiveDisplayContext] $Context,
        [Spectre.Console.Layout] $LayoutComponent,
        [System.Collections.Stack] $Messages
    )

    $rows = @()

    foreach ($message in $Messages) {
        if ($message.Actor -eq "System") {
            $rows += $message.Message.PadRight(6) `
                | Get-SpectreEscapedText `
                | Write-SpectreHost -Justify Left -PassThru `
                | Format-SpectrePanel -Color Grey -Header "System" `
                | Format-SpectreAligned -HorizontalAlignment Left `
                | Format-SpectrePadded -Top 0 -Left 10 -Bottom 0 -Right 0
        } else {
            $rows += $message.Message.PadRight($message.Actor.Length) `
                | Get-SpectreEscapedText `
                | Write-SpectreHost -Justify Right -PassThru `
                | Format-SpectrePanel -Color Pink1 -Header $message.Actor `
                | Format-SpectreAligned -HorizontalAlignment Right `
                | Format-SpectrePadded -Top 0 -Left 0 -Bottom 0 -Right 10
        }
    }

    # Add the heights of each message until reaching the max size, subtract the height of the title and text entry components (10)
    $availableHeight = $Host.UI.RawUI.WindowSize.Height - 10
    $totalHeight = 0
    $rowsToRender = @()
    foreach ($row in $rows) {
        $totalHeight += ($row | Get-SpectreRenderableSize).Height
        if ($totalHeight -gt $availableHeight) {
            break
        }
        $rowsToRender += $row
    }

    # Stack is LIFO, so we need to reverse it to display the messages in the correct order
    [array]::Reverse($rowsToRender)

    $component = $rowsToRender | Format-SpectreRows | Format-SpectreAligned -VerticalAlignment Top | Format-SpectrePanel -Border None
    $LayoutComponent.Update($component) | Out-Null
    $Context.Refresh()
}

function Update-CustomTextEntryComponent {
    param (
        [Spectre.Console.LiveDisplayContext] $Context,
        [Spectre.Console.Layout] $LayoutComponent,
        [string] $CurrentInput
    )
    $safeInput = [string]::IsNullOrEmpty($CurrentInput) ? "" : ($CurrentInput | Get-SpectreEscapedText)
    $component = "[gray]Prompt:[/] $safeInput" | Format-SpectrePanel -Expand | Format-SpectrePadded -Top 0 -Left 20 -Bottom 0 -Right 20 | Format-SpectreAligned -HorizontalAlignment Center
    $LayoutComponent.Update($component) | Out-Null
    $Context.Refresh()
}

# App logic functions
function Get-SomeChatResponse {
    param (
        [System.Collections.Stack] $Messages,
        [Spectre.Console.LiveDisplayContext] $Context,
        [Spectre.Console.Layout] $LayoutComponent
    )

    # Pretend to be thinking
    $ellipsisCount = 1
    for ($i = 0; $i -lt 3; $i++) {
        $Messages.Push(@{ Actor = "System"; Message = ("." * $ellipsisCount) })
        $ellipsisCount++

        Update-MessageListComponent -Context $Context -LayoutComponent $LayoutComponent -Messages $Messages
        Start-Sleep -Milliseconds 500

        # Remove the last thinking message
        $null = $Messages.Pop()
    }

    # Return the response
    return @{ Actor = "System"; Message = "I don't understand what you're saying." }
}

function Get-LastChatKeyPressed {
    return [Console]::ReadKey($true)
}

# Start live rendering the layout
Invoke-SpectreLive -Data $layout -ScriptBlock {
    param (
        [Spectre.Console.LiveDisplayContext] $Context
    )

    # State
    $messages = [System.Collections.Stack]::new(@(
        @{ Actor = "System"; Message = "👋 Hello, welcome to ChaTTY!" },
        @{ Actor = "System"; Message = "Type your message and press Enter to send it." },
        @{ Actor = "System"; Message = "Use the Up and Down arrow keys to scroll through previous messages." },
        @{ Actor = "System"; Message = "Press 'ctrl-c' to close the chat." }
    ))
    $currentInput = ""

    while ($true) {
        # Update components
        Update-TitleComponent -Context $Context -LayoutComponent $layout["title"]
        Update-MessageListComponent -Context $Context -LayoutComponent $layout["messages"] -Messages $messages
        Update-CustomTextEntryComponent -Context $Context -LayoutComponent $layout["customTextEntry"] -CurrentInput $currentInput

        # Real basic input handling, just add characters and remove if backspace is pressed, submit message if Enter is pressed
        [Console]::TreatControlCAsInput = $true
        $lastKeyPressed = Get-LastChatKeyPressed
        if ($lastKeyPressed.Key -eq "C" -and $lastKeyPressed.Modifiers -eq "Control") {
            # Exit the loop. You have to treat ctrl-c as input to avoid the console readkey blocking the sigint
            return
        } elseif ($lastKeyPressed.Key -eq "Enter") {
            # Add the latest user message to the message stack
            $messages.Push(@{ Actor = ($env:USERNAME + $env:USER); Message = $currentInput })
            $currentInput = ""
            Update-CustomTextEntryComponent -Context $Context -LayoutComponent $layout["customTextEntry"] -CurrentInput $currentInput
            Update-MessageListComponent -Context $Context -LayoutComponent $layout["messages"] -Messages $messages
            $messages.Push((Get-SomeChatResponse -Messages $messages -Context $Context -LayoutComponent $layout["messages"]))
        } elseif($lastKeyPressed.Key -eq "Backspace") {
            # Remove the last character from the current input string
            $currentInput = $currentInput.Substring(0, [Math]::Max(0, $currentInput.Length - 1))
        } elseif ($lastKeyPressed.KeyChar) {
            # Add the character to the current input string
            $currentInput += $lastKeyPressed.KeyChar
        }
    }
}
#>
function Invoke-SpectreLive {
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreLive")]
    param (
        [Parameter(ValueFromPipeline)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [scriptblock] $ScriptBlock
    )

    Start-AnsiConsoleLive -Data $Data -ScriptBlock $ScriptBlock
}