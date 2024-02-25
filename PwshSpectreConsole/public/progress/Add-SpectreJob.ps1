function Add-SpectreJob {
    <#
    .SYNOPSIS
    Adds a Spectre job to a list of jobs.
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .DESCRIPTION
    This function adds a Spectre job to the list of jobs you want to wait for with Wait-SpectreJobs.

    .PARAMETER Context
    The Spectre context to add the job to. The context object is only available inside Invoke-SpectreCommandWithProgress.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER JobName
    The name of the job to add.

    .PARAMETER Job
    The PowerShell job to add to the context.

    .EXAMPLE
    # This is an example of how to use the Add-SpectreJob function to add two jobs to a jobs list that can be passed to Wait-SpectreJobs when you're inside Invoke-SpectreCommandWithProgress.
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
    [Reflection.AssemblyMetadata("title", "Add-SpectreJob")]
    param (
        [Parameter(Mandatory)]
        [Spectre.Console.ProgressContext] $Context,
        [Parameter(Mandatory)]
        [string] $JobName,
        [Parameter(Mandatory)]
        [System.Management.Automation.Job] $Job
    )

    return @{
        Job = $Job
        Task = $Context.AddTask($JobName)
    }
}