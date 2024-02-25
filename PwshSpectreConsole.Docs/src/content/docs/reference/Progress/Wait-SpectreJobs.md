---
title: Wait-SpectreJobs
---



### Synopsis
Waits for Spectre jobs to complete.
:::note
This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
:::

---

### Description

This function waits for Spectre jobs to complete by checking the progress of each job and updating the corresponding task value.
Adapted from https://key2consulting.com/powershell-how-to-display-job-progress/

---

### Examples
Waits for two jobs to complete

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
#### **Context**
The Spectre progress context object.
[https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|true    |1       |false        |

#### **Jobs**
An array of Spectre jobs which are decorated PowerShell jobs.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Array]`|true    |2       |false        |

#### **TimeoutSeconds**
The maximum number of seconds to wait for the jobs to complete. Defaults to 60 seconds.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |3       |false        |

---

### Syntax
```powershell
Wait-SpectreJobs [-Context] <Object> [-Jobs] <Array> [[-TimeoutSeconds] <Int32>] [<CommonParameters>]
```
