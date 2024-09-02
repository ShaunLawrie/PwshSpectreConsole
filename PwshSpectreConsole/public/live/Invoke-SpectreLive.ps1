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
    #return $lastKeyPressed
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