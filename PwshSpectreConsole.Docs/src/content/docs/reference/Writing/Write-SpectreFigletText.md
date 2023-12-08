---
title: Write-SpectreFigletText
---



### Synopsis
Writes a Spectre Console Figlet text to the console.

---

### Description

This function writes a Spectre Console Figlet text to the console. The text can be aligned to the left, right, or centered, and can be displayed in a specified color.

---

### Examples
Displays the text "Hello Spectre!" in the center of the console, in red color.

```powershell
Write-SpectreFigletText -Text "Hello Spectre!" -Alignment "Centered" -Color "Red"
```

---

### Parameters
#### **Text**
The text to display in the Figlet format.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **Alignment**
The alignment of the text. Valid values are "Left", "Right", and "Centered". The default value is "Left".
Valid Values:

* Left
* Right
* Center

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Color**
The color of the text. The default value is the accent color of the script.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

---

### Syntax
```powershell
Write-SpectreFigletText [[-Text] <String>] [[-Alignment] <String>] [[-Color] <String>] [<CommonParameters>]
```

