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
    Invoke-SpectreCommandWithProgress -ScriptBlock {
        param ( $Context )
        
        $jobs = @()
        $jobs += Add-SpectreJob -Context $Context -JobName "Drawing a picture" -Job (
            Start-Job {
                $progress = 0
                while($progress -lt 100) {
                    $progress += 1.5
                    Write-Progress -Activity "Processing" -PercentComplete $progress
                    Start-Sleep -Milliseconds 50
                }
            }
        )
        $jobs += Add-SpectreJob -Context $Context -JobName "Driving a car" -Job (
            Start-Job {
                $progress = 0
                while($progress -lt 100) {
                    $progress += 0.9
                    Write-Progress -Activity "Processing" -PercentComplete $progress
                    Start-Sleep -Milliseconds 50
                }
            }
        )
        
        Wait-SpectreJobs -Context $Context -Jobs $jobs
    }

    .EXAMPLE
    $result = Invoke-SpectreCommandWithProgress -ScriptBlock {
        param ( $Context )
        
        $task1 = $Context.AddTask("Completing a task with an unknown duration")
        $task1.IsIndeterminate = $true
        Start-Sleep -Seconds 5
        $task1.Value = 100

        return "Some result"
    }
    Write-SpectreHost "Result: $result"

    .EXAMPLE
    $result = Invoke-SpectreCommandWithProgress -ScriptBlock {
        param ( $Context )
        
        $job = Add-SpectreJob -Context $Context -JobName "Doing some work" -Job (
            Start-Job {
                Start-Sleep -Seconds 10
                return 1234
            }
        )
        
        Wait-SpectreJobs -Context $Context -Jobs $job -EstimatedDurationSeconds 5
        
        $result = Receive-Job -Job $job.Job
        
        return $result
    }
    Write-SpectreHost "Result: $result"
    #>
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithProgress")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    Start-AnsiConsoleProgress $ScriptBlock
}