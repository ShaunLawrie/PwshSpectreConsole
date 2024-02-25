---
title: Read-SpectrePause
---



### Synopsis
Pauses the script execution and waits for user input to continue.

---

### Description

The Read-SpectrePause function pauses the script execution and waits for user input to continue. It displays a message prompting the user to press the enter key to continue. If the end of the console window is reached, the function clears the message and moves the cursor up to the previous line.

---

### Examples
This example pauses the script execution and displays the message "Press any key to continue...". The function waits for the user to press a key before continuing.

```powershell
Read-SpectrePause -Message "Press any key to continue..."
```

---

### Parameters
#### **Message**
The message to display to the user. The default message is "[<default value color>]Press [<accent color]<enter>[/] to continue[/]".

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **NoNewline**
Indicates whether to write a newline character before displaying the message. By default, a newline character is written.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Read-SpectrePause [[-Message] <String>] [-NoNewline] [<CommonParameters>]
```
