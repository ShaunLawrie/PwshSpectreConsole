---
title: Get-SpectreEscapedText
---



### Synopsis
Escapes text for use in Spectre Console.
[ShaunLawrie/PwshSpectreConsole/issues/5](https://github.com/ShaunLawrie/PwshSpectreConsole/issues/5)

---

### Description

This function escapes text for use where Spectre Console accepts markup. It is intended to be used as a helper function for other functions that output text to the console using Spectre Console which contains special characters that need escaping.
See [https://spectreconsole.net/markup](https://spectreconsole.net/markup) for more information about the markup language used in Spectre Console.

---

### Examples
This example shows some data that requires escaping being embedded in a string passed to Format-SpectrePanel.

```powershell
$data = "][[][]]][[][][]["
Format-SpectrePanel -Title "Unescaped data" -Data "I want escaped $($data | Get-SpectreEscapedText) [yellow]and[/] [red]unescaped[/] data"
```

---

### Parameters
#### **Text**
The text to be escaped.

|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[String]`|true    |1       |true (ByValue)|

---

### Syntax
```powershell
Get-SpectreEscapedText [-Text] <String> [<CommonParameters>]
```
