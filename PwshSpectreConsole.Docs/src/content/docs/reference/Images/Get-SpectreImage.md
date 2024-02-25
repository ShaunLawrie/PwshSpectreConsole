---
title: Get-SpectreImage
---



### Synopsis
Displays an image in the console using CanvasImage.

---

### Description

Displays an image in the console using CanvasImage. The image can be resized to a maximum width if desired.

---

### Examples
Displays the image located at "C:\Images\myimage.png" with a maximum width of 80 characters.

```powershell
Get-SpectreImage -ImagePath "C:\Images\myimage.png" -MaxWidth 80
```

---

### Parameters
#### **ImagePath**
The path to the image file to be displayed.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **MaxWidth**
The maximum width of the image. If not specified, the image will be displayed at its original size.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |2       |false        |

---

### Syntax
```powershell
Get-SpectreImage [[-ImagePath] <String>] [[-MaxWidth] <Int32>] [<CommonParameters>]
```
