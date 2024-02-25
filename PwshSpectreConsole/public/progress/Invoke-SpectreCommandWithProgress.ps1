function Invoke-SpectreCommandWithProgress {
    <#
    .SYNOPSIS
    Invokes a Spectre command with a progress bar.

    .DESCRIPTION
    This function takes a script block as a parameter and executes it while displaying a progress bar. The context and task objects are defined at [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/).
    The context requires at least one task to be added for progress to be displayed. The task object is used to update the progress bar by calling the Increment() method or other methods defined in Spectre console [https://spectreconsole.net/api/spectre.console/progresstask/](https://spectreconsole.net/api/spectre.console/progresstask/).

    .PARAMETER ScriptBlock
    The script block to execute.

    .EXAMPLE
    # This example will display a progress bar while the script block is executing.
    Invoke-SpectreCommandWithProgress -ScriptBlock {
        param (
            $Context
        )
        $task1 = $Context.AddTask("Completing a four stage process")
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
        $task1.Increment(25)
        Start-Sleep -Seconds 1
    }

    .EXAMPLE
    # This example will display a progress bar while multiple background jobs are running.
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
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithProgress")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    Start-AnsiConsoleProgress $ScriptBlock
}