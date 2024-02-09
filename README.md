# 👻 PwshSpectreConsole

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![GitHub license](https://img.shields.io/github/license/ShaunLawrie/PwshSpectreConsole)](https://github.com/ShaunLawrie/PwshSpectreConsole/blob/main/LICENSE)

PwshSpectreConsole is a wrapper for the [awesome Spectre.Console library](https://spectreconsole.net/).
Spectre Console is mostly an async library and it leans heavily on types and extension methods in C# which are very verbose to work with in PowerShell so this module hides away some of the complexity.  

The module doesn't expose the full feature set of Spectre.Console because the scope of the library is huge and I've focused on the features that I can use to enhance my scripts. If you have a feature request, please raise an issue on the GitHub repo or open a PR.

## Installation

```pwsh
Install-Module PwshSpectreConsole -Scope CurrentUser
Start-SpectreDemo
```

## Documentation

Full documentation at [https://pwshspectreconsole.com/](https://pwshspectreconsole.com/)

![image](/PwshSpectreConsole/private/webpreview.png)
