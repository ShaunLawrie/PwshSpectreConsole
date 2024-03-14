Import-NamespaceFromCsFile -Namespace "PwshSpectreConsole.Recording"

function Stop-SpectreRecording {
    <#
        .SYNOPSIS
            Stops a recording of the current console output and returns the recording.
        .DESCRIPTION
            Stops a recording of the current console output and returns the recording.
        .PARAMETER Title
            The title of the recording, only used for asciinema recordings.
        .PARAMETER OutputPath
            The path to save the recording to.
        .EXAMPLE
            $recording = Start-SpectreRecording -RecordingType "Html" -CountdownAndClear
            # Use spectre console functions, these will be recorded
            Write-SpectreHost "Hello [red]world[/]"
            # Finish the recording
            $result = Stop-SpectreRecording
            # Output the results
            Write-SpectreHost "Result:`n$result"
    #>
    [Reflection.AssemblyMetadata("title", "Stop-SpectreRecording")]
    param (
        [string] $Title,
        [string] $OutputPath
    )

    if(!$global:SpectreRecordingType) {
        Write-Warning "No recording in progress"
        return
    }

    if(!$Title) {
        $Title = "Asciinema Recording"
    }

    # Get the recording
    switch ($global:SpectreRecordingType) {
        "asciinema" {
            $recording = $global:SpectreRecordingRecorder.GetAsciiCastRecording($Title)
        }
        "text" {
            $recording = [Spectre.Console.RecorderExtensions]::ExportText($global:SpectreRecordingRecorder)
        }
        "html" {
            $recording = [Spectre.Console.RecorderExtensions]::ExportHtml($global:SpectreRecordingRecorder)
        }
    }

    # Reset the console
    [Spectre.Console.AnsiConsole]::Console = $global:SpectreRecordingOriginalConsole
    
    # Return the output
    if ($OutputPath) {
        Set-Content -Path $OutputPath -Value $recording
        Write-Host "Saved recording to '$OutputPath'"
    } else {
        return $recording
    }
}