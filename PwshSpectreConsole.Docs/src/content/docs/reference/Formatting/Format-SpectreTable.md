---
title: Format-SpectreTable
---







### Synopsis
Formats an array of objects into a Spectre Console table. Thanks to [trackd](https://github.com/trackd) and [fmotion1](https://github.com/fmotion1) for the updates to support markdown and color in the table contents.
![Example table](/table.png)



---


### Description

This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.



---


### Examples
This example formats an array of objects into a table with a double border and the accent color of the script.

```powershell
$data = @(
    [pscustomobject]@{Name="John"; Age=25; City="New York"},
    [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
)
Format-SpectreTable -Data $data
```


---


### Parameters
#### **Property**

The list of properties to select for the table from the input data.






|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |1       |false        |



#### **Data**

The array of objects to be formatted into a table.






|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|true    |named   |true (ByValue)|



#### **Border**

The border style of the table. Default is "Double".



Valid Values:

* Ascii
* Ascii2
* AsciiDoubleHead
* Double
* DoubleEdge
* Heavy
* HeavyEdge
* HeavyHead
* Horizontal
* Markdown
* Minimal
* MinimalDoubleHead
* MinimalHeavyHead
* None
* Rounded
* Simple
* SimpleHeavy
* Square






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |



#### **Color**

The color of the table border. Default is the accent color of the script.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |



#### **Width**

The width of the table.






|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |named   |false        |



#### **HideHeaders**

Hides the headers of the table.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |



#### **Title**

The title of the table.






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |



#### **AllowMarkup**

Allow Spectre markup in the table elements e.g. [green]message[/].






|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |





---


### Syntax
```powershell
Format-SpectreTable [[-Property] <String[]>] -Data <Object> [-Border <String>] [-Color <String>] [-Width <Int32>] [-HideHeaders] [-Title <String>] [-AllowMarkup] [<CommonParameters>]
```
