function Add-SpectreJob {
    <#
    .SYNOPSIS
    Adds a Spectre job to a list of jobs.

    .DESCRIPTION
    This function adds a Spectre job to the list of jobs you want to wait for with Wait-SpectreJobs.
    :::note
    This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
    :::

    .PARAMETER Context
    The Spectre context to add the job to. The context object is only available inside Invoke-SpectreCommandWithProgress.
    [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

    .PARAMETER JobName
    The name of the job to add.

    .PARAMETER Job
    The PowerShell job to add to the context.

    .EXAMPLE
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
        Job  = $Job
        Task = $Context.AddTask($JobName)
    }
}