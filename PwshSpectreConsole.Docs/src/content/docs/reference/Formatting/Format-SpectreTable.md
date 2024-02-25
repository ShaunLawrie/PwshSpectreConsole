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
> EXAMPLE 2

```powershell
$Properties = @(
    # foreground + background
    @{'Name'='FileName'; Expression={ "[orange1 on blue]" + $_.Name + "[/]" }},
    # foreground
    @{'Name'='Last Updated'; Expression={ "[DeepSkyBlue3_1]" + $_.LastWriteTime.ToString() + "[/]" }},
    # background
    @{'Name'='Drive'; Expression={ "[default on orange1]" + (Split-Path $_.Fullname -Qualifier) + "[/]" }}
)
Get-ChildItem | Format-SpectreTable -Property $Properties -AllowMarkup
```
> EXAMPLE 3

```powershell
1..10 | Format-SpectreTable -Title Numbers
```

---

### Parameters
#### **Data**
The array of objects to be formatted into a table.
Takes pipeline input.

|Type      |Required|Position|PipelineInput |Aliases    |
|----------|--------|--------|--------------|-----------|
|`[Object]`|true    |named   |true (ByValue)|InputObject|

#### **Property**
Specifies the object properties that appear in the display and the order in which they appear.
Type one or more property names, separated by commas, or use a hash table to display a calculated property.
Wildcards are permitted.
The Property parameter is optional. You can't use the Property and View parameters in the same command.
The value of the Property parameter can be a new calculated property.
The calculated property can be a script block or a hash table. Valid key-value pairs are:
* Name (or Label) `<string>`
* Expression - `<string>` or `<script block>`
* FormatString - `<string>`
* Width - `<int32>` - must be greater than `0`
* Alignment - value can be `Left`, `Center`, or `Right`

|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[Object[]]`|false   |1       |false        |

#### **Wrap**
Displays text that exceeds the column width on the next line. By default, text that exceeds the column width is truncated
Currently there is a bug with this, spectre.console/issues/1185

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **View**
The View parameter lets you specify an alternate format or custom view for the table.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |named   |false        |

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

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |named   |false        |

#### **HeaderColor**
The color of the table header text. Default is the DefaultTableHeaderColor.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |named   |false        |

#### **TextColor**
The color of the table text. Default is the DefaultTableTextColor.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |named   |false        |

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
Format-SpectreTable -Data <Object> [-Wrap] [-Border <String>] [-Color <Color>] [-HeaderColor <Color>] [-TextColor <Color>] [-Width <Int32>] [-HideHeaders] [-Title <String>] [-AllowMarkup] [<CommonParameters>]
```
```powershell
Format-SpectreTable -Data <Object> [[-Property] <Object[]>] [-Wrap] [-Border <String>] [-Color <Color>] [-HeaderColor <Color>] [-TextColor <Color>] [-Width <Int32>] [-HideHeaders] [-Title <String>] [-AllowMarkup] [<CommonParameters>]
```
```powershell
Format-SpectreTable -Data <Object> [-Wrap] [-View <String>] [-Border <String>] [-Color <Color>] [-HeaderColor <Color>] [-TextColor <Color>] [-Width <Int32>] [-HideHeaders] [-Title <String>] [-AllowMarkup] [<CommonParameters>]
```
