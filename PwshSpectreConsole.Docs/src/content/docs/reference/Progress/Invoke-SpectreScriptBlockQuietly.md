---
sidebar:
  badge:
    text: Experimental
    variant: caution
title: Invoke-SpectreScriptBlockQuietly
---







### Synopsis
A testing function for invoking a script block in a background job inside Invoke-SpectreCommandWithProgress to help with https://github.com/ShaunLawrie/PwshSpectreConsole/issues/7



---


### Description

This function invokes a script block in a background job and returns the output. It also provides an option to suppress the output even more if there is garbage being printed to stderr if using Level = Quieter.



---


### Examples
This example invokes the git command in a background job and suppresses the output completely even though it would have written to stderr and thrown an error.

```powershell
Invoke-SpectreScriptBlockQuietly -Level Quieter -Command {
    git checkout nonexistentbranch
    if($LASTEXITCODE -ne 0) {
        throw "Failed to checkout nonexistentbranch"
    }
}
```


---


### Parameters
#### **Command**

The script block to be invoked.






|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|false   |1       |false        |



#### **Level**

Suppresses the output completely if this switch is specified.



Valid Values:

* Quiet
* Quieter






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```powershell
Invoke-SpectreScriptBlockQuietly [[-Command] <ScriptBlock>] [-Level] [<CommonParameters>]
```
