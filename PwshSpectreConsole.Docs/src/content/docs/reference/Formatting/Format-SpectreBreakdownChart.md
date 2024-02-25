---
title: Format-SpectreBreakdownChart
---



### Synopsis
Formats data into a breakdown chart.
![Example breakdown chart](/breakdownchart.png)

---

### Description

This function takes an array of data and formats it into a breakdown chart using BreakdownChart. The chart can be customized with a specified width and color.

---

### Examples
This example uses the new helper for generating chart items New-SpectreChartItem and the various ways of passing color values in.

```powershell
$data = @()
$data += New-SpectreChartItem -Label "Apples" -Value 10 -Color "Green"
$data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "Gold1"
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

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |2       |false        |

#### **HideTags**
Hides the tags on the chart.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **HideTagValues**
Hides the tag values on the chart.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Format-SpectreBreakdownChart [-Data] <Array> [[-Width] <Int32>] [-HideTags] [-HideTagValues] [<CommonParameters>]
```
