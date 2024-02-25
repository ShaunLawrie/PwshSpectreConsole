---
title: Write-SpectreFigletText
---



### Synopsis
Writes a Spectre Console Figlet text to the console.

---

### Description

This function writes a Spectre Console Figlet text to the console. The text can be aligned to the left, right, or center, and can be displayed in a specified color.

---

### Examples
Displays the text "Hello Spectre!" in the center of the console, in red color.

```powershell
Write-SpectreFigletText -Text "Hello Spectre!" -Alignment "Center" -Color "Red"
```
Displays the text "Woah!" using a custom figlet font.

```powershell
Write-SpectreFigletText -Text "Whoa?!" -FigletFontPath "C:\Users\shaun\Downloads\3d.flf"
 ██       ██ ██                          ████  ██
░██      ░██░██                         ██░░██░██
░██   █  ░██░██       ██████   ██████  ░██ ░██░██
░██  ███ ░██░██████  ██░░░░██ ░░░░░░██ ░░  ██ ░██
░██ ██░██░██░██░░░██░██   ░██  ███████    ██  ░██
░████ ░░████░██  ░██░██   ░██ ██░░░░██   ░░   ░░
░██░   ░░░██░██  ░██░░██████ ░░████████   ██   ██
░░       ░░ ░░   ░░  ░░░░░░   ░░░░░░░░   ░░   ░░
```

---

### Parameters
#### **Text**
The text to display in the Figlet format.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **Alignment**
The alignment of the text. The default value is "Left".
Valid Values:

* Left
* Right
* Center

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Color**
The color of the text. The default value is the accent color of the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

#### **FigletFontPath**
The path to the Figlet font file to use. If this parameter is not specified, the default built-in Figlet font is used.
The figlet font format is usually *.flf, see https://spectreconsole.net/widgets/figlet for more.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |

---

### Syntax
```powershell
Write-SpectreFigletText [[-Text] <String>] [[-Alignment] <String>] [[-Color] <Color>] [[-FigletFontPath] <String>] [<CommonParameters>]
```
