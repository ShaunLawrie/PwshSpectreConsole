---
title: Read-SpectreSelection
---



### Synopsis
Displays a selection prompt using Spectre Console.

---

### Description

This function displays a selection prompt using Spectre Console. The user can select an option from the list of choices provided. The function returns the selected option.

---

### Examples
This command displays a selection prompt with the title "Select your favorite color" and the choices "Red", "Green", and "Blue". The active selection is colored in green.

```powershell
Read-SpectreSelection -Title "Select your favorite color" -Choices @("Red", "Green", "Blue") -Color "Green"
```

---

### Parameters
#### **Title**
The title of the selection prompt.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **Choices**
The list of choices to display in the selection prompt. ChoiceLabelProperty is required if the choices are complex objects rather than an array of strings.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Array]`|false   |2       |false        |

#### **ChoiceLabelProperty**
If the object is complex then the property of the choice object to use as the label in the selection prompt is required.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **Color**
The color of the selected option in the selection prompt.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |4       |false        |

#### **PageSize**
The number of choices to display per page in the selection prompt.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |5       |false        |

---

### Syntax
```powershell
Read-SpectreSelection [[-Title] <String>] [[-Choices] <Array>] [[-ChoiceLabelProperty] <String>] [[-Color] <Color>] [[-PageSize] <Int32>] [<CommonParameters>]
```
