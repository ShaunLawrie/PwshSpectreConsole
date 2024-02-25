---
title: Read-SpectreMultiSelection
---



### Synopsis
Displays a multi-selection prompt using Spectre Console and returns the selected choices.

---

### Description

This function displays a multi-selection prompt using Spectre Console and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The function supports customizing the title, choices, choice label property, color, and page size of the prompt.

---

### Examples
Displays a multi-selection prompt with the title "Select your favourite fruits", the list of fruits, the "Name" property as the label for each fruit, the color green for highlighting the selected fruits, and 3 fruits per page.

```powershell
Read-SpectreMultiSelection -Title "Select your favourite fruits" -Choices @("apple", "banana", "orange", "pear", "strawberry") -Color "Green" -PageSize 3
```

---

### Parameters
#### **Title**
The title of the prompt. Defaults to "What are your favourite [color]?".

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
The color to use for highlighting the selected choices. Defaults to the accent color of the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |4       |false        |

#### **PageSize**
The number of choices to display per page. Defaults to 5.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |5       |false        |

#### **AllowEmpty**
Allow the multi-selection to be submitted without any options chosen.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Read-SpectreMultiSelection [[-Title] <String>] [[-Choices] <Array>] [[-ChoiceLabelProperty] <String>] [[-Color] <Color>] [[-PageSize] <Int32>] [-AllowEmpty] [<CommonParameters>]
```
