Import-NamespaceFromCsFile -Namespace "PwshSpectreConsole.Recording"

$global:SpectreRecordingRecorder = $null
$global:SpectreRecordingOriginalConsole = $null
$global:SpectreRecordingType = $null

function Start-SpectreRecording {
    <#
        .SYNOPSIS
            Starts a recording of the current console output. This can be used to record a demo of a script or module.
        .DESCRIPTION
            Starts a recording of the current console output. This can be used to record all of the spectre console interactions in a PowerShell session.  
            I've used this to record the examples on the docs help site.
            :::caution
            This is experimental.
            :::
        .PARAMETER Width
            The width of the recording.
        .PARAMETER Height
            The height of the recording.
        .PARAMETER RecordingType
            The type of recording to create.
        .PARAMETER CountdownAndClear
            If this switch is present, the console will be cleared and a countdown will be displayed before the recording starts.
        .PARAMETER Quiet
            If this switch is present all terminal output from spectre console will be suppressed, it will not be visible on the terminal.
        .EXAMPLE
            $recording = Start-SpectreRecording -RecordingType "Html" -CountdownAndClear
            # Use spectre console functions, these will be recorded
            Write-SpectreHost "Hello [red]world[/]"
            # Finish the recording
            $result = Stop-SpectreRecording
            # Output the results
            Write-SpectreHost "Result:`n$result"
    #>
    [Reflection.AssemblyMetadata("title", "Start-SpectreRecording")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope = 'Function', Target = '*')]
    param(
        [int] $Width = (Get-HostWidth),
        [int] $Height = (Get-HostHeight),
        [ValidateSet("asciinema", "text", "html")]
        [string] $RecordingType = "asciinema",
        [switch] $CountdownAndClear,
        [switch] $Quiet
    )

    if(!$global:SpectreRecordingType) {
        throw "A $global:SpectreRecordingType recording has already started"
    }

    if($CountdownAndClear) {
        function Test-Recording {
            for($i = 3; $i -gt 0; $i--) {
                [Console]::CursorVisible = $false
                Write-SpectreHost "`r:red_circle: Recording starting in $i"
                Start-Sleep -Seconds 1
                Write-SpectreHost ("`e[1A                                  " | Get-SpectreEscapedText) -NoNewline
            }
            Write-SpectreHost ("`rRecording started" | Get-SpectreEscapedText)
            [Console]::CursorVisible = $true
        }
    }

    $global:SpectreRecordingOriginalConsole = [Spectre.Console.AnsiConsole]::Console

    if($RecordingType -eq "asciinema") {
        # Create a recording console for asciinema, it's a bit fiddlier and requires an iansiconsole that can record durations between frames
        $global:SpectreRecordingRecorder = [PwshSpectreConsole.Recording.RecordingConsole]::new($width, $height, $quiet)
    } else {
        # Use the built in recorder
        $global:SpectreRecordingRecorder = [Spectre.Console.Recorder]::new($global:SpectreRecordingOriginalConsole)
    }

    # Override current spectre console instance
    $global:SpectreRecordingType = $RecordingType
    [Spectre.Console.AnsiConsole]::Console = $global:SpectreRecordingRecorder

    return $global:SpectreRecordingRecorder
}
