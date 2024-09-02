function Wait-SpectreJobs {
    <#
    .SYNOPSIS
    Waits for Spectre jobs to complete.

    .DESCRIPTION
    This function waits for Spectre jobs to complete by checking the progress of each job and updating the corresponding task value.
    Adapted from https://key2consulting.com/powershell-how-to-display-job-progress/
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .PARAMETER Context
    The Spectre progress context object.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER Jobs
    An array of Spectre jobs which are decorated PowerShell jobs.

    .PARAMETER TimeoutSeconds
    The maximum number of seconds to wait for the jobs to complete. Defaults to 60 seconds.

    .PARAMETER EstimatedDurationSeconds
    The estimated duration of the jobs in seconds. This is used to calculate the progress of the jobs if the job progress is not available.

    .EXAMPLE
    # **Example 1**
    # This example demonstrates how to add two jobs to a context and wait for them to complete.
    Invoke-SpectreCommandWithProgress -ScriptBlock {
        param (
            $Context
        )
        $jobs = @()
        $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 2 })
        $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 4 })
        Wait-SpectreJobs -Context $Context -Jobs $jobs
    }
    #>
    [Reflection.AssemblyMetadata("title", "Wait-SpectreJobs")]
    param (
        [Parameter(Mandatory)]
        [object] $Context,
        [Parameter(Mandatory)]
        [array] $Jobs,
        [int] $TimeoutSeconds = 60,
        [int] $EstimatedDurationSeconds
    )

    $start = Get-Date
    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)

    while (!$Context.IsFinished) {
        if ((Get-Date) -gt $timeout) {
            throw "Timed out waiting for jobs after $TimeoutSeconds seconds"
        }
        $completedJobs = 0
        foreach ($job in $Jobs) {
            if ($job.Job.State -ne "Running") {
                $job.Task.Value = 100.0
                $completedJobs++
                continue
            }
            $progress = 0.0
            if ($job.Job.ChildJobs[0].Progress) {
                $progress = $job.Job.ChildJobs[0].Progress | Select-Object -Last 1 -ExpandProperty "PercentComplete"
            } elseif($EstimatedDurationSeconds) {
                $estimatedProgress = ((Get-Date) - $start).TotalSeconds / $EstimatedDurationSeconds * 100
                if($estimatedProgress -gt 99) {
                    # Job is only estimated to be finished, switch to an indeterminate one now
                    $progress = 99
                    if(!$job.Task.IsIndeterminate) {
                        $job.Task.IsIndeterminate = $true
                    }
                } else {
                    $progress = $estimatedProgress
                }
            }
            $job.Task.Value = $progress
        }
        Start-Sleep -Milliseconds 100
    }
}