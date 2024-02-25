---
title: Add-SpectreJob
---



### Synopsis
Adds a Spectre job to a list of jobs.
:::note
This is only used inside `Invoke-SpectreCommandWithProgress` where the Spectre ProgressContext object is exposed.
:::

---

### Description

This function adds a Spectre job to the list of jobs you want to wait for with Wait-SpectreJobs.

---

### Examples
This is an example of how to use the Add-SpectreJob function to add two jobs to a jobs list that can be passed to Wait-SpectreJobs when you're inside Invoke-SpectreCommandWithProgress.

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
The Spectre context to add the job to. The context object is only available inside Invoke-SpectreCommandWithProgress.
[https://spectreconsole.net/api/spectre.console/progresscontext/](https://spectreconsole.net/api/spectre.console/progresscontext/)

|Type               |Required|Position|PipelineInput|
|-------------------|--------|--------|-------------|
|`[ProgressContext]`|true    |1       |false        |

#### **JobName**
The name of the job to add.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|true    |2       |false        |

#### **Job**
The PowerShell job to add to the context.

|Type   |Required|Position|PipelineInput|
|-------|--------|--------|-------------|
|`[Job]`|true    |3       |false        |

---

### Syntax
```powershell
Add-SpectreJob [-Context] <ProgressContext> [-JobName] <String> [-Job] <Job> [<CommonParameters>]
```
