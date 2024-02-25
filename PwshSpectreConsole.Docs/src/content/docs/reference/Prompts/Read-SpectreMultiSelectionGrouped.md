---
title: Read-SpectreMultiSelectionGrouped
---



### Synopsis
Displays a multi-selection prompt with grouped choices and returns the selected choices.

---

### Description

Displays a multi-selection prompt with grouped choices and returns the selected choices. The prompt allows the user to select one or more choices from a list of options. The choices can be grouped into categories, and the user can select choices from each category.

---

### Examples
This example displays a multi-selection prompt with two groups of choices: "Primary Colors" and "Secondary Colors". The prompt uses the "Name" property of each choice as the label. The user can select one or more choices from each group.

```powershell
Read-SpectreMultiSelectionGrouped -Title "Select your favorite colors" -Choices @(
    @{
        Name = "Primary Colors"
        Choices = @("Red", "Blue", "Yellow")
    },
    @{
        Name = "Secondary Colors"
        Choices = @("Green", "Orange", "Purple")
    }
)
```

---

### Parameters
#### **Title**
The title of the prompt. The default value is "What are your favourite [color]?".

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **Choices**
An array of choice groups. Each group is a hashtable with two keys: "Name" and "Choices". The "Name" key is a string that represents the name of the group, and the "Choices" key is an array of strings that represents the choices in the group.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Array]`|false   |2       |false        |

#### **ChoiceLabelProperty**
The name of the property to use as the label for each choice. If this parameter is not specified, the choices are displayed as strings.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **Color**
The color of the selected choices. The default value is the accent color of the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |4       |false        |

#### **PageSize**
The number of choices to display per page. The default value is 10.

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
Read-SpectreMultiSelectionGrouped [[-Title] <String>] [[-Choices] <Array>] [[-ChoiceLabelProperty] <String>] [[-Color] <Color>] [[-PageSize] <Int32>] [-AllowEmpty] [<CommonParameters>]
```
