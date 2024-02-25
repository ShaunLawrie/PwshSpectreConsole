---
sidebar:
  badge:
    text: Experimental
    variant: caution
title: Get-SpectreImageExperimental
---



### Synopsis
Displays an image in the console using block characters and ANSI escape codes.
:::caution
This is experimental.
:::

---

### Description

This function loads an image from a file and displays it in the console using block characters and ANSI escape codes. The image is scaled to fit within the specified maximum width while maintaining its aspect ratio. If the image is an animated GIF, each frame is displayed in sequence with a configurable delay between frames.

---

### Examples
Displays the image "MyImage.png" in the console with a maximum width of 80 characters.

```powershell
PS C:\> Get-SpectreImageExperimental -ImagePath "C:\Images\MyImage.png" -MaxWidth 80
```
Displays the animated GIF "MyAnimation.gif" in the console with a maximum width of 80 characters, repeating indefinitely. Press ctrl-c to stop the animation.

```powershell
PS C:\> Get-SpectreImageExperimental -ImagePath "C:\Images\MyAnimation.gif" -MaxWidth 80
```

---

### Parameters
#### **ImagePath**
The path to the image file to display.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **ImageUrl**
The URL to the image file to display. If specified, the image is downloaded to a temporary file and then displayed.

|Type   |Required|Position|PipelineInput|
|-------|--------|--------|-------------|
|`[Uri]`|false   |2       |false        |

#### **Width**
The width of the image in characters. The image is scaled to fit within this width while maintaining its aspect ratio.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |3       |false        |

#### **LoopCount**
The number of times to repeat the animation. The default value is 0, which means the animation will repeat forever. Press ctrl-c to stop the animation.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |4       |false        |

#### **Resampler**
The resampling algorithm to use when scaling the image. Valid values are "Bicubic" and "NearestNeighbor". The default value is "Bicubic".
Valid Values:

* Bicubic
* NearestNeighbor

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |5       |false        |

---

### Syntax
```powershell
Get-SpectreImageExperimental [[-ImagePath] <String>] [[-ImageUrl] <Uri>] [[-Width] <Int32>] [[-LoopCount] <Int32>] [[-Resampler] <String>] [<CommonParameters>]
```
