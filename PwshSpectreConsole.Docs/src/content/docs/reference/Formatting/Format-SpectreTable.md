---
title: Format-SpectreTable
---



### Synopsis
Formats an array of objects into a Spectre Console table.
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
#### **Data**
The array of objects to be formatted into a table.

|Type     |Required|Position|PipelineInput |
|---------|--------|--------|--------------|
|`[Array]`|true    |1       |true (ByValue)|

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
|`[String]`|false   |2       |false        |

#### **Color**
The color of the table border. Default is the accent color of the script.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **Width**
The width of the table.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |4       |false        |

#### **HideHeaders**
Hides the headers of the table.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Title**
The title of the table.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |5       |false        |

---

### Syntax
```powershell
Format-SpectreTable [-Data] <Array> [[-Border] <String>] [[-Color] <String>] [[-Width] <Int32>] [-HideHeaders] [[-Title] <String>] [<CommonParameters>]
```

