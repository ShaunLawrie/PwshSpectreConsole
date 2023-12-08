---
title: Invoke-SpectreCommandWithStatus
---



### Synopsis
Invokes a script block with a Spectre status spinner.

---

### Description

This function starts a Spectre status spinner with the specified title and spinner type, and invokes the specified script block. The spinner will continue to spin until the script block completes.

---

### Examples
Starts a Spectre status spinner with the "dots" spinner type, a yellow color, and the title "Waiting for process to complete". The spinner will continue to spin for 5 seconds.

```powershell
Invoke-SpectreCommandWithStatus -ScriptBlock { Start-Sleep -Seconds 5 } -Spinner dots -Title "Waiting for process to complete" -Color yellow
```

---

### Parameters
#### **ScriptBlock**
The script block to invoke.

|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[ScriptBlock]`|true    |1       |false        |

#### **Spinner**
The type of spinner to display. Valid values are "dots", "dots2", "dots3", "dots4", "dots5", "dots6", "dots7", "dots8", "dots9", "dots10", "dots11", "dots12", "line", "line2", "pipe", "simpleDots", "simpleDotsScrolling", "star", "star2", "flip", "hamburger", "growVertical", "growHorizontal", "balloon", "balloon2", "noise", "bounce", "boxBounce", "boxBounce2", "triangle", "arc", "circle", "squareCorners", "circleQuarters", "circleHalves", "squish", "toggle", "toggle2", "toggle3", "toggle4", "toggle5", "toggle6", "toggle7", "toggle8", "toggle9", "toggle10", "toggle11", "toggle12", "toggle13", "arrow", "arrow2", "arrow3", "bouncingBar", "bouncingBall", "smiley", "monkey", "hearts", "clock", "earth", "moon", "runner", "pong", "shark", "dqpb", "weather", "christmas", "grenade", "point", "layer", "betaWave", "pulse", "noise2", "gradient", "christmasTree", "santa", "box", "simpleDotsDown", "ballotBox", "checkbox", "radioButton", "spinner", "lineSpinner", "lineSpinner2", "pipeSpinner", "simpleDotsSpinner", "ballSpinner", "balloonSpinner", "noiseSpinner", "bouncingBarSpinner", "smileySpinner", "monkeySpinner", "heartsSpinner", "clockSpinner", "earthSpinner", "moonSpinner", "auto", "random".
Valid Values:

* Aesthetic
* Arc
* Arrow
* Arrow2
* Arrow3
* Ascii
* Balloon
* Balloon2
* BetaWave
* Bounce
* BouncingBall
* BouncingBar
* BoxBounce
* BoxBounce2
* Christmas
* Circle
* CircleHalves
* CircleQuarters
* Clock
* Default
* Dots
* Dots10
* Dots11
* Dots12
* Dots2
* Dots3
* Dots4
* Dots5
* Dots6
* Dots7
* Dots8
* Dots8Bit
* Dots9
* Dqpb
* Earth
* Flip
* Grenade
* GrowHorizontal
* GrowVertical
* Hamburger
* Hearts
* Layer
* Line
* Line2
* Material
* Monkey
* Moon
* Noise
* Pipe
* Point
* Pong
* Runner
* Shark
* SimpleDots
* SimpleDotsScrolling
* Smiley
* SquareCorners
* Squish
* Star
* Star2
* Toggle
* Toggle10
* Toggle11
* Toggle12
* Toggle13
* Toggle2
* Toggle3
* Toggle4
* Toggle5
* Toggle6
* Toggle7
* Toggle8
* Toggle9
* Triangle
* Weather

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Title**
The title to display above the spinner.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|true    |3       |false        |

#### **Color**
The color of the spinner. Valid values can be found with Get-SpectreDemoColors.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |

---

### Syntax
```powershell
Invoke-SpectreCommandWithStatus [-ScriptBlock] <ScriptBlock> [[-Spinner] <String>] [-Title] <String> [[-Color] <String>] [<CommonParameters>]
```

