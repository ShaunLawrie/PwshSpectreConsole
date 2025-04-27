$script:SpectreRecordingRecorder = $null
$script:SpectreRecordingOriginalConsole = $null
$script:SpectreRecordingType = $null

function Start-SpectreRecording {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/config/start-spectrerecording/')]
    <#
        .SYNOPSIS
            Starts a recording of the current console output. This can be used to record a demo of a script or module.
        .DESCRIPTION
            Starts a recording of the current console output. This can be used to record all of the spectre console interactions in a PowerShell session.  
            I've used this to record the examples on the docs help site.
            :::caution
            This is experimental.  
            Experimental features are unstable and subject to change.
            :::
        .PARAMETER Width
            The width of the recording.
        .PARAMETER Height
            The height of the recording.
        .PARAMETER RecordingType
            The type of recording to create.
        .PARAMETER CountdownAndClear
            If this switch is present, the console will be cleared and a countdown will be displayed before the recording starts.
        .EXAMPLE
            # **Example 1**  
            # This example demonstrates how to record the spectre console output.
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
        [switch] $CountdownAndClear
    )

    if($script:SpectreRecordingType) {
        throw "A $script:SpectreRecordingType recording has already started"
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

    $script:SpectreRecordingOriginalConsole = [Spectre.Console.AnsiConsole]::Console

    if($RecordingType -eq "asciinema") {
        # Create a recording console for asciinema, it's a bit fiddlier and requires an iansiconsole that can record durations between frames
        $script:SpectreRecordingRecorder = [PwshSpectreConsole.Recording.RecordingConsole]::new($width, $height)
    } else {
        # Use the built in recorder
        $script:SpectreRecordingRecorder = [Spectre.Console.Recorder]::new($script:SpectreRecordingOriginalConsole)
    }

    # Override current spectre console instance
    $script:SpectreRecordingType = $RecordingType
    [Spectre.Console.AnsiConsole]::Console = $script:SpectreRecordingRecorder

    return $script:SpectreRecordingRecorder
}
