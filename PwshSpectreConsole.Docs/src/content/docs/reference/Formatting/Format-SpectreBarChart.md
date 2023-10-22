---
title: Format-SpectreBarChart
---







### Synopsis
Formats and displays a bar chart using the Spectre Console module.



---


### Description

This function takes an array of data and displays it as a bar chart using the Spectre Console module. The chart can be customized with a title and width.



---


### Examples
This example displays a bar chart with the title "Fruit Sales" and a width of 50 characters.

```powershell
PS> $data = @(
    @{ Label = "Apples"; Value = 10; Color = [Spectre.Console.Color]::Green },
    @{ Label = "Oranges"; Value = 5; Color = [Spectre.Console.Color]::Yellow },
    @{ Label = "Bananas"; Value = 3; Color = [Spectre.Console.Color]::Red }
)
PS> Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
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
|`[Object]`|false   |2       |false        |



#### **Width**

The width of the chart in characters.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Object]`|false   |3       |false        |





---


### Syntax
```powershell
Format-SpectreBarChart [-Data] <Array> [[-Title] <Object>] [[-Width] <Object>] [<CommonParameters>]
```

