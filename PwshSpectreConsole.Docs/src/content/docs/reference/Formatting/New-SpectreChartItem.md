---
sidebar:
  badge:
    text: New
    variant: tip
title: New-SpectreChartItem
---



### Synopsis
Creates a new SpectreChartItem object.

---

### Description

The New-SpectreChartItem function creates a new SpectreChartItem object with the specified label, value, and color for use in Format-SpectreBarChart and Format-SpectreBreakdownChart.

---

### Examples
This example creates an array of new SpectreChartItem objects you can pass into the chart functions.

```powershell
$data = @()
$data += New-SpectreChartItem -Label "Sales" -Value 1000 -Color "green"
$data += New-SpectreChartItem -Label "Expenses" -Value 500 -Color "#ff0000"
$data += New-SpectreChartItem -Label "Profit" -Value 500 -Color ([Spectre.Console.Color]::Blue)
```

---

### Parameters
#### **Label**
The label for the chart item.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|true    |1       |false        |

#### **Value**
The value for the chart item.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Double]`|true    |2       |false        |

#### **Color**
The color for the chart item. Must be a valid Spectre color as name, hex or a Spectre.Console.Color object.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|true    |3       |false        |

---

### Syntax
```powershell
New-SpectreChartItem [-Label] <String> [-Value] <Double> [-Color] <Color> [<CommonParameters>]
```
