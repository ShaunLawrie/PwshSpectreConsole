---
sidebar:
  badge:
    text: New
    variant: tip
title: Write-SpectreCalendar
---



### Synopsis
Writes a Spectre Console Calendar text to the console.

---

### Description

Writes a Spectre Console Calendar text to the console.

---

### Examples
This example shows how to use the Write-SpectreCalendar function with an events table defined as a hashtable in the command.

```powershell
Write-SpectreCalendar -Date 2024-07-01 -Events @{'2024-07-10' = 'Beach time!'; '2024-07-20' = 'Barbecue' }
```
This example shows how to use the Write-SpectreCalendar function with an events table as an object argument.

```powershell
$events = @{
    '2024-01-10' = 'Hello World!'
    '2024-01-20' = 'Hello Universe!'
}
Write-SpectreCalendar -Date 2024-01-01 -Events $events
```

---

### Parameters
#### **Date**
The date to display the calendar for.

|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[DateTime]`|false   |1       |false        |

#### **Alignment**
The alignment of the calendar.
Valid Values:

* Left
* Right
* Center

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Color**
The color of the calendar.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

#### **Border**
The border of the calendar.
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
|`[String]`|false   |4       |false        |

#### **Culture**
The culture of the calendar.

|Type           |Required|Position|PipelineInput|
|---------------|--------|--------|-------------|
|`[CultureInfo]`|false   |5       |false        |

#### **Events**
The events to highlight on the calendar.
Takes a hashtable with the date as the key and the event as the value.

|Type         |Required|Position|PipelineInput|
|-------------|--------|--------|-------------|
|`[Hashtable]`|false   |6       |false        |

#### **HideHeader**
Hides the header of the calendar. (Date)

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Write-SpectreCalendar [[-Date] <DateTime>] [[-Alignment] <String>] [[-Color] <Color>] [[-Border] <String>] [[-Culture] <CultureInfo>] [[-Events] <Hashtable>] [-HideHeader] [<CommonParameters>]
```
