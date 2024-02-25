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

This function uses Spectre Console to prompt the user with a question and returns the user's input.

---

### Examples
This will prompt the user with the question "What's your name?" and return the user's input. If the user does not provide any input, the function will return "Prefer not to say".

```powershell
Read-SpectreText -Question "What's your name?" -DefaultAnswer "Prefer not to say"
```
This will prompt the user with the question "What's your favorite color?" and return the user's input.

```powershell
Read-SpectreText -Question "What's your favorite color?" -AnswerColor "Cyan1" -Choices "Black", "Green","Magenta", "I'll never tell!"
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

#### **AnswerColor**
The color of the user's answer input. The default behaviour uses the standard terminal text color.

|Type     |Required|Position|PipelineInput|
|---------|--------|--------|-------------|
|`[Color]`|false   |3       |false        |

#### **AllowEmpty**
If specified, the user can provide an empty answer.

|Type      |Required|Position|PipelineInput|
|----------|--------|--------|-------------|
|`[Switch]`|false   |named   |false        |

#### **Choices**
An array of choices that the user can choose from. If specified, the user will be prompted with a list of choices to choose from, with validation.
With autocomplete and can tab through the choices.

|Type        |Required|Position|PipelineInput|
|------------|--------|--------|-------------|
|`[String[]]`|false   |4       |false        |

---

### Syntax
```powershell
Read-SpectreText [[-Question] <String>] [[-DefaultAnswer] <String>] [[-AnswerColor] <Color>] [-AllowEmpty] [[-Choices] <String[]>] [<CommonParameters>]
```
