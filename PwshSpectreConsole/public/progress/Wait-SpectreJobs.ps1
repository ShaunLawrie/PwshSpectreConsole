function Wait-SpectreJobs {
    <#
    .SYNOPSIS
    Waits for Spectre jobs to complete.
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .DESCRIPTION
    This function waits for Spectre jobs to complete by checking the progress of each job and updating the corresponding task value.
    Adapted from https://key2consulting.com/powershell-how-to-display-job-progress/

    .PARAMETER Context
    The Spectre progress context object.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER Jobs
    An array of Spectre jobs which are decorated PowerShell jobs.

    .PARAMETER TimeoutSeconds
    The maximum number of seconds to wait for the jobs to complete. Defaults to 60 seconds.

    .EXAMPLE
    # Waits for two jobs to complete
    Invoke-SpectreCommandWithProgress -ScriptBlock {
        param (
            $Context
        )
        $jobs = @()
        $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 5 })
        $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 10 })
        Wait-SpectreJobs -Context $Context -Jobs $jobs
    }
    #>
    [Reflection.AssemblyMetadata("title", "Wait-SpectreJobs")]
    param (
        [Parameter(Mandatory)]
        [object] $Context,
        [Parameter(Mandatory)]
        [array] $Jobs,
        [int] $TimeoutSeconds = 60
    )

    $timeout = (Get-Date).AddSeconds($TimeoutSeconds)

    while(!$Context.IsFinished) {
        if((Get-Date) -gt $timeout) {
            throw "Timed out waiting for jobs after $TimeoutSeconds seconds"
        }
        $completedJobs = 0
        foreach($job in $Jobs) {
            if($job.Job.State -ne "Running") {
                $job.Task.Value = 100.0
                $completedJobs++
                continue
            }
            $progress = 0.0
            if($null -ne $job.Job.ChildJobs[0].Progress) {
                $progress = $job.Job.ChildJobs[0].Progress | Select-Object -Last 1 -ExpandProperty "PercentComplete"
            }
            $job.Task.Value = $progress
        }
        Start-Sleep -Milliseconds 100
    }
}