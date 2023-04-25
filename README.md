# PwshSpectreConsole

> **Warning**  
> This is a very early work in progress, the function formats and parameters are likely to be unstable while I work out how to interface with the Spectre.Console from PowerShell

[![Build](https://img.shields.io/github/actions/workflow/status/ShaunLawrie/PwshSpectreConsole/test.yml)](https://github.com/ShaunLawrie/PwshSpectreConsole/actions/workflows/test.yml)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![GitHub license](https://img.shields.io/github/license/ShaunLawrie/PwshSpectreConsole)](https://github.com/ShaunLawrie/PwshSpectreConsole/blob/main/LICENSE)

PwshSpectreConsole is an opinionated wrapper for the [awesome Spectre.Console library](https://spectreconsole.net/).
It's opinionated in that I have not just exposed the internals of Spectre Console to PowerShell but have wrapped them in a way that makes them work better in the PowerShell ecosystem. Spectre Console is mostly an async library and it leans heavily on types and extension methods in C# which are very verbose to work with in PowerShell so this module hides away some of the complexity.  

The module doesn't expose the full feature set of Spectre.Console because the scope of the library is huge and I've focused on the features that I can use to enhance my scripts.

# Installation
```pwsh
Install-Module PwshSpectreConsole -Scope CurrentUser
```

# Usage

PwshSpectreConsole exposes the following functions for you to use in your scripts:

## Special for PowerShell Compatibility
| Command                               | Example                                                                              | Effect                                                                                                                                                   |
| ------------------------------------- | ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Set-SpectreColors**                 | `Set-SpectreColors -Accent ([Spectre.Console.Color]::HotPink)`                       | Sets the default color used by all widgets as hot pink.                                                                                                  |
| **Add-SpectreJob**                    | `$jobs = Add-SpectreJob -Context $ctx -JobName "Drawing a picture" -Job $job`        | Must be used inside an Invoke-SpectreCommand* command. This adds a parallel job to the current command context so that the progress will be reported on. |
| **Wait-SpectreJobs**                  | `Wait-SpectreJobs -Jobs $jobs -TimeoutSeconds 120`                                   | Waits up to 120 seconds for the jobs to be completed.                                                                                                    |
| **Invoke-SpectreCommandWithProgress** | `Invoke-SpectreCommandWithProgress { param ($ctx) <# do some work #> }`              | Shows progress bars while the provided scriptblock is running. The $ctx var is the Spectre.Console Context variable.                                     |
| **Invoke-SpectreCommandWithStatus**   | `Invoke-SpectreCommandWithStatus { param ($ctx) <# do some work #> }`                | Shows a spinner while the provided scriptblock is running. The $ctx var is the Spectre.Console Context variable.                                         |
| **Invoke-SpectrePromptAsync**         | `Invoke-SpectrePromptAsync -Prompt $prompt`                                          | Given a Spectre.Console prompt object this will execute the prompt asynchronously with a workaround to allow ctrl-c to still interrupt the execution.    |
| **Read-SpectrePause**                 | `Read-SpectrePause`                                                                  | Pauses execution of the script asking the user to press enter when they're ready to continue.                                                            |

| Command                       | Example                                                                              | Output |
| ----------------------------- | ------------------------------------------------------------------------------------ | ------ |
| **Write-SpectreFigletText**   | `Write-FigletText -Text "Hello PowerShell!"`                                         | Implements https://spectreconsole.net/widgets/figlet |
| **Write-SpectreRule**         | `Write-SectionTitle -Text "Important Section"`                                       | Implements https://spectreconsole.net/widgets/rule |
| **Write-SpectreParagraph**    | `Write-Paragraph -Text $(25 * "lots of words")`                                      | A convenience wrapper for PowerShell to wrap words properly when they extend beyond the width of the console window.    |
| **Get-SpectreSelection**      | `Get-Selection -Text "What's your favourite flavor? -Options @("sweet", "savoury")"` | Implements https://spectreconsole.net/prompts/selection |

> **Warning**  
> Documentation of the functions is incomplete
