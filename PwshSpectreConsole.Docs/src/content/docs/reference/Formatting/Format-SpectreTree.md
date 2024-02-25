---
title: Format-SpectreTree
---



### Synopsis
Formats a hashtable as a tree using Spectre Console.

---

### Description

This function takes a hashtable and formats it as a tree using Spectre Console. The hashtable should have a 'Label' key and a 'Children' key. The 'Label' key should contain the label for the root node of the tree, and the 'Children' key should contain an array of hashtables representing the child nodes of the root node. Each child hashtable should have a 'Label' key and a 'Children' key, following the same structure as the root node.

---

### Examples
This example formats a hashtable as a tree with a heavy border and green color.

```powershell
$data = @{
    Label = "Root"
    Children = @(
        @{
            Label = "Child 1"
            Children = @(
                @{
                    Label = "Grandchild 1"
                    Children = @()
                },
                @{
                    Label = "Grandchild 2"
                    Children = @()
                }
            )
        },
        @{
            Label = "Child 2"
            Children = @()
        }
    )
}
Format-SpectreTree -Data $data -Guide BoldLine -Color "Green"
```

---

### Parameters
#### **Data**
The hashtable to format as a tree.

|Type         |Required|Position|PipelineInput |
|-------------|--------|--------|--------------|
|`[Hashtable]`|true    |1       |true (ByValue)|

#### **Guide**

Valid Values:

* Ascii
* BoldLine
* DoubleLine
* Line

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **Color**
The color to use for the tree. This can be a Spectre Console color name or a hex color code. Default is the accent color defined in the script.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

---

### Syntax
```powershell
Format-SpectreTree [-Data] <Hashtable> [[-Guide] <String>] [[-Color] <Color>] [<CommonParameters>]
```
