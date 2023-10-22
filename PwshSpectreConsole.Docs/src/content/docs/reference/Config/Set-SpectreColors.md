---
title: Set-SpectreColors
---







### Synopsis
Sets the accent color and default value color for Spectre Console.



---


### Description

This function sets the accent color and default value color for Spectre Console. The accent color is used for highlighting important information, while the default value color is used for displaying default values.



---


### Examples
Sets the accent color to Red and the default value color to Yellow.

```powershell
PS> Set-SpectreColors -AccentColor Red -DefaultValueColor Yellow
```
Sets the accent color to Green and keeps the default value color as Grey.

```powershell
PS> Set-SpectreColors -AccentColor Green
```


---


### Parameters
#### **AccentColor**

The accent color to set. Must be a valid Spectre Console color name. Defaults to "Blue".






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |



#### **DefaultValueColor**

The default value color to set. Must be a valid Spectre Console color name. Defaults to "Grey".






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |





---


### Syntax
```powershell
Set-SpectreColors [[-AccentColor] <String>] [[-DefaultValueColor] <String>] [<CommonParameters>]
```

