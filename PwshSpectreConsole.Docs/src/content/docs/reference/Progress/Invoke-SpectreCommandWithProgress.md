---
title: Invoke-SpectreCommandWithProgress
---



### Synopsis
Invokes a Spectre command with a progress bar.

---

### Description

This function takes a script block as a parameter and executes it while displaying a progress bar. The context and task objects are defined at [https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/).
The context requires at least one task to be added for progress to be displayed. The task object is used to update the progress bar by calling the Increment() method or other methods defined in Spectre console [https://spectreconsole.net/api/spectre.console/progresstask/](https://spectreconsole.net/api/spectre.console/progresstask/).

---

### Examples
This example will display a progress bar while the script block is executing.

```powershell
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
```
This example will display a progress bar while multiple background jobs are running.

```powershell
Invoke-SpectreCommandWithProgress -ScriptBlock {
    param (
        $Context
    )
    $jobs = @()
    $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 5 })
    $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 10 })
    Wait-SpectreJobs -Context $Context -Jobs $jobs
}
```

---

### Parameters
#### **ScriptBlock**
The script block to execute.

|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|true    |1       |false        |

---

### Syntax
```powershell
Invoke-SpectreCommandWithProgress [-ScriptBlock] <ScriptBlock> [<CommonParameters>]
```
