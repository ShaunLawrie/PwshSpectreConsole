<#
.SYNOPSIS
    This is a test function for invoking a script block in a background job inside Invoke-SpectreCommandWithProgress to help with https://github.com/ShaunLawrie/PwshSpectreConsole/issues/7  
    Some commands cause output that interferes with the progress bar, this function is an attempt to suppress that output when all other attempts have failed.
    :::caution
    This is experimental.
    :::
.DESCRIPTION
    This function invokes a script block in a background job and returns the output. It also provides an option to suppress the output even more if there is garbage being printed to stderr if using Level = Quieter.
.EXAMPLE
    # This example invokes the git command in a background job and suppresses the output completely even though it would have written to stderr and thrown an error.
    Invoke-SpectreScriptBlockQuietly -Level Quieter -Command {
        git checkout nonexistentbranch
        if($LASTEXITCODE -ne 0) {
            throw "Failed to checkout nonexistentbranch"
        }
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
        $job = Start-Job $Command
        $job | Wait-Job | Out-Null

        if($job.State -eq "Failed") {
            $job | Receive-Job
            throw "Failed to execute script block"
        }
        
        switch($Level) {
            "Quiet" {
                return ($job | Receive-Job)
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