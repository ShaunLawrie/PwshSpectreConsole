---
sidebar:
  badge:
    text: New
    variant: tip
title: Format-SpectreJson
---



### Synopsis
Formats an array of objects into a Spectre Console Json.
Thanks to [trackd](https://github.com/trackd) for adding this.
![Spectre json example](/json.png)

---

### Description

This function takes an array of objects and converts them into Json using the Spectre Console Json Library.

---

### Examples
This example formats an array of objects into a table with a double border and the accent color of the script.

```powershell
$data = @(
    [pscustomobject]@{
        Name = "John"
        Age = 25
        City = "New York"
        IsEmployed = $true
        Salary = 10
        Hobbies = @("Reading", "Swimming")
        Address = @{
            Street = "123 Main St"
            ZipCode = $null
        }
    },
    [pscustomobject]@{
        Name = "Jane"
        Age = 30
        City = "Los Angeles"
        IsEmployed = $false
        Salary = $null
        Hobbies = @("Painting", "Hiking")
        Address = @{
            Street = "456 Elm St"
            ZipCode = "90001"
        }
    }
)
Format-SpectreJson -Data $data -Title "Employee Data" -Border "Rounded" -Color "Green"
```

---

### Parameters
#### **Data**
The array of objects to be formatted into Json.

|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[Object]`|true    |1       |true (ByValue)|

#### **Depth**
The maximum depth of the Json. Default is defined by the version of powershell.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |2       |false        |

#### **Title**
The title of the Json.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |3       |false        |

#### **NoBorder**
If specified, the Json will not be surrounded by a border.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Border**
The border style of the Json. Default is "Rounded".
Valid Values:

* Ascii
* Double
* Heavy
* None
* Rounded
* Square

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |4       |false        |

#### **Color**
The color of the Json border. Default is the accent color of the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |5       |false        |

#### **Width**
The width of the Json panel.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |6       |false        |

#### **Height**
The height of the Json panel.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Int32]`|false   |7       |false        |

#### **Expand**

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Format-SpectreJson [-Data] <Object> [[-Depth] <Int32>] [[-Title] <String>] [-NoBorder] [[-Border] <String>] [[-Color] <Color>] [[-Width] <Int32>] [[-Height] <Int32>] [-Expand] [<CommonParameters>]
```
