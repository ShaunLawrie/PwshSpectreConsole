---
title: Write-SpectreHost
description: The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.
---



### Synopsis
Writes a message to the console using Spectre Console markup.

---

### Description

The Write-SpectreHost function writes a message to the console using Spectre Console. It supports ANSI markup and can optionally append a newline character to the end of the message.
The markup language is defined at [https://spectreconsole.net/markup](https://spectreconsole.net/markup)
Supported emoji are defined at [https://spectreconsole.net/appendix/emojis](https://spectreconsole.net/appendix/emojis)

---

### Examples
This example writes the message "Hello, world!" to the console with the word world flashing blue with an underline followed by an emoji throwing a shaka.

```powershell
Write-SpectreHost -Message "Hello, [blue underline rapidblink]world[/]! :call_me_hand:"
```

---

### Parameters
#### **Message**
The message to write to the console.

|Type      |Required|Position|PipelineInput |
|----------|--------|--------|--------------|
|`[String]`|true    |1       |true (ByValue)|

#### **NoNewline**
If specified, the message will not be followed by a newline character.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Write-SpectreHost [-Message] <String> [-NoNewline] [<CommonParameters>]
```
