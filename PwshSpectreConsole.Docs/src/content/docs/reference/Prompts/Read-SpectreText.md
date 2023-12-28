---
title: Read-SpectreText
---



### Synopsis
Prompts the user with a question and returns the user's input.
:::caution
I would advise against this and instead use `Read-Host` because the Spectre Console prompt doesn't have access to the PowerShell session history. This means that you can't use the up and down arrow keys to navigate through your previous commands.
:::

---

### Description

This function uses Spectre Console to prompt the user with a question and returns the user's input. The function takes two parameters: $Question and $DefaultAnswer. $Question is the question to prompt the user with, and $DefaultAnswer is the default answer if the user does not provide any input.

---

### Examples
This will prompt the user with the question "What's your name?" and return the user's input. If the user does not provide any input, the function will return "Prefer not to say".

```powershell
Read-SpectreText -Question "What's your name?" -DefaultAnswer "Prefer not to say"
```

---

### Parameters
#### **Question**
The question to prompt the user with.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |1       |false        |

#### **DefaultAnswer**
The default answer if the user does not provide any input.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[String]`|false   |2       |false        |

#### **AllowEmpty**
If specified, the user can provide an empty answer.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

---

### Syntax
```powershell
Read-SpectreText [[-Question] <String>] [[-DefaultAnswer] <String>] [-AllowEmpty] [<CommonParameters>]
```

