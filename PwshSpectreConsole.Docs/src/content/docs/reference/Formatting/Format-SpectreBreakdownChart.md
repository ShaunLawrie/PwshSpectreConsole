---
title: Format-SpectreBreakdownChart
---







### Synopsis
Formats data into a breakdown chart.



---


### Description

This function takes an array of data and formats it into a breakdown chart using Spectre.Console.BreakdownChart. The chart can be customized with a specified width and color.



---


### Examples
This example displays a breakdown chart with the title "Fruit Sales" and a width of 50 characters.

```powershell
$data = @(
    @{ Label = "Apples"; Value = 10; Color = "Red" },
    @{ Label = "Oranges"; Value = 20; Color = "Orange1" },
    @{ Label = "Bananas"; Value = 15; Color = "Yellow" }
)
Format-SpectreBreakdownChart -Data $data -Width 50
```
This example uses the new helper for generating chart items New-SpectreChartItem and the various ways of passing color values in.

```powershell
$data = @()
$data += New-SpectreChartItem -Label "Apples" -Value 10 -Color [Spectre.Console.Color]::Green
$data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "Orange"
$data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"

Format-SpectreBreakdownChart -Data $data -Width 50
```


---


### Parameters
#### **Data**

An array of data to be formatted into a breakdown chart.






|Type     |Required|Position|PipelineInput |
|---------|--------|--------|--------------|
|`[Array]`|true    |1       |true (ByValue)|



#### **Width**

The width of the chart. Defaults to the width of the console.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|false   |2       |false        |





---


### Syntax
```powershell
Format-SpectreBreakdownChart [-Data] <Array> [[-Width] <Object>] [<CommonParameters>]
```

