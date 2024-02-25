---
title: Set-SpectreColors
---



### Synopsis
Sets the accent color and default value color for Spectre Console.

---

### Description

This function sets the accent color and default value color for Spectre Console. The accent color is used for highlighting important information, while the default value color is used for displaying default values.

An example of the accent color is the highlight used in `Read-SpectreSelection`:  
![Accent color example](/accentcolor.png)

An example of the default value color is the default value displayed in `Read-SpectreText`:  
![Default value color example](/defaultcolor.png)

---

### Examples
Sets the accent color to Red and the default value color to Yellow.

```powershell
Set-SpectreColors -AccentColor Red -DefaultValueColor Yellow
```
Sets the accent color to Green and keeps the default value color as Grey.

```powershell
Set-SpectreColors -AccentColor Green
```

---

### Parameters
#### **AccentColor**
The accent color to set. Must be a valid Spectre Console color name. Defaults to "Blue".

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |1       |false        |

#### **DefaultValueColor**
The default value color to set. Must be a valid Spectre Console color name. Defaults to "Grey".

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |2       |false        |

#### **DefaultTableHeaderColor**
The default table header color to set. Must be a valid Spectre Console color name. Defaults to "Default" which will be the standard console foreground color.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

#### **DefaultTableTextColor**
The default table text color to set. Must be a valid Spectre Console color name. Defaults to "Default" which will be the standard console foreground color.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |4       |false        |

---

### Syntax
```powershell
Set-SpectreColors [[-AccentColor] <Color>] [[-DefaultValueColor] <Color>] [[-DefaultTableHeaderColor] <Color>] [[-DefaultTableTextColor] <Color>] [<CommonParameters>]
```
