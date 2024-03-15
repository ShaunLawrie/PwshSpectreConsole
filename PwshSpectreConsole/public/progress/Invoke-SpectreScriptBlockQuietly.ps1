<#
.SYNOPSIS
    This is a test function for invoking a script block in a background job inside Invoke-SpectreCommandWithProgress to help with https://github.com/ShaunLawrie/PwshSpectreConsole/issues/7  
    Some commands cause output that interferes with the progress bar, this function is an attempt to suppress that output when all other attempts have failed.
    
.DESCRIPTION
    This function invokes a script block in a background job and returns the output. It also provides an option to suppress the output even more if there is garbage being printed to stderr if using Level = Quieter.

.EXAMPLE
    Invoke-SpectreCommandWithProgress {
        param (
            $Context
        )
        $task1 = $Context.AddTask("Starting a process that generates noise")
        $task1.Increment(50)
        $value = Invoke-SpectreScriptBlockQuietly -Level Quiet -Command {
            Write-Output "Things..."
            Write-Output "And stuff..."
            Write-Error "This is an error"
            Start-Sleep -Seconds 3
            git checkout nonexistentbranch
            Write-Output "But it shouldn't break progress bar rendering"
        }
        $task1.Increment(50)
        return $value
    }
#>
function Invoke-SpectreScriptBlockQuietly {
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreScriptBlockQuietly")]
    param (
        # The script block to be invoked.
        [scriptblock] $Command,
        # Suppresses the output by varying amounts.
        [ValidateSet("Quiet", "Quieter")]
        [string] $Level = "Quiet"
    )
    try {
        $job = Start-ThreadJob $Command
        $job | Wait-Job | Out-Null

        if ($job.State -eq "Failed") {
            $job | Receive-Job
            throw "Failed to execute script block"
        }
        
        switch ($Level) {
            "Quiet" {
                $output = $job | Receive-Job 2>$null
                return $output
            }
            "Quieter" {
                return
            }
            default {
                throw "Invalid value for Level parameter"
            }
        }
    } finally {
        $job | Stop-Job -ErrorAction SilentlyContinue
        $job | Remove-Job -Force -ErrorAction SilentlyContinue
    }
}