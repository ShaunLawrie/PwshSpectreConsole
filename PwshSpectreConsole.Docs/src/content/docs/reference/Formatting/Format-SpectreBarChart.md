---
title: Format-SpectreBarChart
---



### Synopsis
Formats and displays a bar chart using the Spectre Console module.
![Example bar chart](/barchart.png)

---

### Description

This function takes an array of data and displays it as a bar chart using the Spectre Console module. The chart can be customized with a title and width.

---

### Examples
This example uses the new helper for generating chart items New-SpectreChartItem and shows the various ways of passing color values in

```powershell
$data = @()
$data += New-SpectreChartItem -Label "Apples" -Value 10 -Color "Green"
$data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "DarkOrange"
$data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"

Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
```

---

### Parameters
#### **Data**
An array of objects containing the data to be displayed in the chart. Each object should have a Label, Value, and Color property.

|Type     |Required|Position|PipelineInput |
|---------|--------|--------|--------------|
|`[Array]`|true    |1       |true (ByValue)|

#### **Title**
The title to be displayed above the chart.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Width**
The width of the chart in characters.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |3       |false        |

#### **HideValues**
Hides the values from being displayed on the chart.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Format-SpectreBarChart [-Data] <Array> [[-Title] <String>] [[-Width] <Int32>] [-HideValues] [<CommonParameters>]
```
