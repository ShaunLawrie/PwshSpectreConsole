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
Displays the animated GIF "MyAnimation.gif" in the console with a maximum width of 80 characters, repeating indefinitely.

```powershell
PS C:\> Get-SpectreImageExperimental -ImagePath "C:\Images\MyAnimation.gif" -MaxWidth 80 -Repeat
```


---


### Parameters
#### **ImagePath**

The path to the image file to display.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |



#### **Width**

The width of the image in characters. The image is scaled to fit within this width while maintaining its aspect ratio.






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |2       |false        |



#### **LoopCount**




|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |3       |false        |



#### **Resampler**

The resampling algorithm to use when scaling the image. Valid values are "Bicubic" and "NearestNeighbor". The default value is "Bicubic".



Valid Values:

* Bicubic
* NearestNeighbor






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |





---


### Syntax
```powershell
Get-SpectreImageExperimental [[-ImagePath] <String>] [[-Width] <Int32>] [[-LoopCount] <Int32>] [[-Resampler] <String>] [<CommonParameters>]
```
