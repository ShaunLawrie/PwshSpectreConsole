# 👻 PwshSpectreConsole

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![GitHub license](https://img.shields.io/github/license/ShaunLawrie/PwshSpectreConsole)](https://github.com/ShaunLawrie/PwshSpectreConsole/blob/main/LICENSE)

PwshSpectreConsole is a wrapper for the [awesome Spectre.Console library](https://spectreconsole.net/).
I have not just exposed the internals of Spectre Console to PowerShell (you can do that yourself by importing the DLLs) but have wrapped them in a way that makes them work better in the PowerShell ecosystem (in my opinion).  
Spectre Console is mostly an async library and it leans heavily on types and extension methods in C# which are very verbose to work with in PowerShell so this module hides away some of the complexity.  

The module doesn't expose the full feature set of Spectre.Console because the scope of the library is huge and I've focused on the features that I can use to enhance my scripts.

# Installation
```pwsh
Install-Module PwshSpectreConsole -Scope CurrentUser
Start-SpectreDemo
```

![Demo](/PwshSpectreConsole/private/demo.gif)

# Usage

PwshSpectreConsole exposes the following functions for you to use in your scripts:

> **Note**  
> Documentation of the functions is incomplete, run `Start-SpectreDemo` for example code using the functions below.

| Command                               | Description                                                                                                                                                             |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Add-SpectreJob**                    | Must be used inside an Invoke-SpectreCommand* command. This adds a parallel job to the current command context so that the progress will be reported on.                |
| **Format-SpectreBarChart**            | Draws a bar chart from some data.                                                                                                                                       |
| **Format-SpectreBreakdownChart**      | Draws a breakdown chart from some data.                                                                                                                                 |
| **Format-SpectrePanel**               | Write some text inside a box.                                                                                                                                           |
| **Format-SpectreTable**               | Like the builtin PowerShell Format-Table but not as useful, it does look pretty though.                                                                                 |
| **Format-SpectreTree**                | Represent a hashtable as a tree if it has the nodes with a property called Label and an array called Children.                                                          |
| **Get-SpectreImage**                  | Draw an image from a file to the terminal.                                                                                                                              |
| **Invoke-SpectreCommandWithProgress** | Shows progress bars while the provided scriptblock is running. The $ctx var is the Spectre.Console Context variable.                                                    |
| **Invoke-SpectreCommandWithStatus**   | Shows a spinner while the provided scriptblock is running. The $ctx var is the Spectre.Console Context variable.                                                        |
| **Invoke-SpectrePromptAsync**         | Given a Spectre.Console prompt object this will execute the prompt asynchronously with a workaround to allow ctrl-c to still interrupt the execution.                   |
| **Read-SpectreMultiSelection**        | Given a list of choices let the user pick multiple options.                                                                                                             |
| **Read-SpectreMultiSelectionGrouped** | Given a list of choices that have been categorised, let the user pick multiple options.                                                                                 |
| **Read-SpectrePause**                 | Prompt the user to press enter to continue.                                                                                                                             |
| **Read-SpectreSelection**             | Given a list of choices allow the user to pick one.                                                                                                                     |
| **Read-SpectreText**                  | Ask the user to provide text input. Read-Host is usually better.                                                                                                        |
| **Set-SpectreColors**                 | Set the default accent and default colors for the Spectre visualisations.                                                                                               |
| **Start-SpectreDemo**                 | Start the spectre interactive demo to show all the features and how they can be used.                                                                                   |
| **Wait-SpectreJobs**                  | Wait for all spectre jobs to complete.                                                                                                                                  |
| **Write-SpectreFigletText**           | Write a message in ASCII art text.                                                                                                                                      |
| **Write-SpectreHost**                 | Write a message to the console that uses Spectre markup formatting. This is the method to use while in a progress scriptblock so that it doesn't break Spectre visuals. |
| **Write-SpectreParagraph**            | A helper function to write large blocks of text so that words don't get split across lines and sentences are broken by whitespace.                                      |
| **Write-SpectreRule**                 | Write a horizontal rule with a message in it.                                                                                                                           |
