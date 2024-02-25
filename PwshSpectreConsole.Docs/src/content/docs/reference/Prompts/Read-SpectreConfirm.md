---
title: Read-SpectreConfirm
---



### Synopsis
Displays a simple confirmation prompt with the option of selecting yes or no and returns a boolean representing the answer.

---

### Description

Displays a simple confirmation prompt with the option of selecting yes or no. Additional options are provided to display either a success or failure response message in addition to the boolean return value.

---

### Examples
This example displays a simple prompt. The user can select either yes or no [Y/n]. A different message is displayed based on the user's selection. The prompt uses the AnsiConsole.MarkupLine convenience method to support colored text and other supported markup. 

```powershell
$readSpectreConfirmSplat = @{
    Prompt = "Would you like to continue the preview installation of [#7693FF]PowerShell 7?[/]"
    ConfirmSuccess = "Woohoo! The internet awaits your elite development contributions."
    ConfirmFailure = "What kind of monster are you? How could you do this?"
}
Read-SpectreConfirm @readSpectreConfirmSplat
```

---

### Parameters
#### **Prompt**
The prompt to display to the user. The default value is "Do you like cute animals?".

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **DefaultAnswer**
The default answer to the prompt if the user just presses enter. The default value is "y".
Valid Values:

* y
* n
* none

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **ConfirmSuccess**
The text and markup to display if the user chooses yes. If left undefined, nothing will display.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **ConfirmFailure**
The text and markup to display if the user chooses no. If left undefined, nothing will display.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |

#### **Color**

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |5       |false        |

---

### Syntax
```powershell
Read-SpectreConfirm [[-Prompt] <String>] [[-DefaultAnswer] <String>] [[-ConfirmSuccess] <String>] [[-ConfirmFailure] <String>] [[-Color] <Color>] [<CommonParameters>]
```
