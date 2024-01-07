# 👻 PwshSpectreConsole

[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PwshSpectreConsole)](https://www.powershellgallery.com/packages/PwshSpectreConsole)
[![GitHub license](https://img.shields.io/github/license/ShaunLawrie/PwshSpectreConsole)](https://github.com/ShaunLawrie/PwshSpectreConsole/blob/main/LICENSE)

PwshSpectreConsole is a wrapper for the [awesome Spectre.Console library](https://spectreconsole.net/).
I have not just exposed the internals of Spectre Console to PowerShell (you can do that yourself by importing the DLLs) but have wrapped them in a way that makes them work better in the PowerShell ecosystem (in my opinion).  
Spectre Console is mostly an async library and it leans heavily on types and extension methods in C# which are very verbose to work with in PowerShell so this module hides away some of the complexity.  

The module doesn't expose the full feature set of Spectre.Console because the scope of the library is huge and I've focused on the features that I can use to enhance my scripts.

## Documentation

Full documentation at [https://pwshspectreconsole.com/](https://pwshspectreconsole.com/)

![image](https://github.com/ShaunLawrie/PwshSpectreConsole/assets/13159458/b7a544fc-ab30-43e7-acfa-1bf6d00ec49f)

## Installation

```pwsh
Install-Module PwshSpectreConsole -Scope CurrentUser
Start-SpectreDemo
```

![Demo](/PwshSpectreConsole/private/demo.gif)
