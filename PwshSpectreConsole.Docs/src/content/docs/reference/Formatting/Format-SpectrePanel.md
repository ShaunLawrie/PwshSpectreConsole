---
title: Format-SpectrePanel
---



### Synopsis
Formats a string as a Spectre Console panel with optional title, border, and color.
![Spectre panel example](/panel.png)

---

### Description

This function takes a string and formats it as a Spectre Console panel with optional title, border, and color. The resulting panel can be displayed in the console using the Write-Host command.

---

### Examples
This example displays a panel with the title "My Panel", a rounded border, and a red border color.

```powershell
Format-SpectrePanel -Data "Hello, world!" -Title "My Panel" -Border "Rounded" -Color "Red"
```

---

### Parameters
#### **Data**
The string to be formatted as a panel.

|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|true    |1       |true (ByValue)|

#### **Title**
The title to be displayed at the top of the panel.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Border**
The type of border to be displayed around the panel.
Valid Values:

* Ascii
* Double
* Heavy
* None
* Rounded
* Square

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **Expand**
Switch parameter that specifies whether the panel should be expanded to fill the available space.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Color**
The color of the panel border.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |4       |false        |

#### **Width**
The width of the panel.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |5       |false        |

#### **Height**
The height of the panel.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |6       |false        |

---

### Syntax
```powershell
Format-SpectrePanel [-Data] <Object> [[-Title] <String>] [[-Border] <String>] [-Expand] [[-Color] <Color>] [[-Width] <Int32>] [[-Height] <Int32>] [<CommonParameters>]
```
