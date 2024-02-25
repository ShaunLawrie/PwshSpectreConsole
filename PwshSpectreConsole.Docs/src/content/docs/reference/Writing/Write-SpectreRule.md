---
title: Write-SpectreRule
---



### Synopsis
Writes a Spectre horizontal-rule to the console.

---

### Description

The Write-SpectreRule function writes a Spectre horizontal-rule to the console with the specified title, alignment, and color.

---

### Examples
This example writes a Spectre rule with the title "My Rule", centered alignment, and red color.

```powershell
Write-SpectreRule -Title "My Rule" -Alignment Center -Color Red
```

---

### Parameters
#### **Title**
The title of the rule.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|true    |1       |false        |

#### **Alignment**
The alignment of the text in the rule. The default value is Left.
Valid Values:

* Left
* Right
* Center

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Color**
The color of the rule. The default value is the accent color of the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

---

### Syntax
```powershell
Write-SpectreRule [-Title] <String> [[-Alignment] <String>] [[-Color] <Color>] [<CommonParameters>]
```
