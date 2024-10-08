---
title: Install
description: Get started with PwshSpectre Console.
---

PwshSpectreConsole is a wrapper for the awesome [Spectre Console](https://spectreconsole.net/) which you can use to make your PowerShell scripts more interesting.

Install PwshSpectreConsole from PSGallery using the following command in your terminal (this requires PowerShell 7+):

```powershell
Install-Module PwshSpectreConsole -Scope CurrentUser
```

<a class="not-content" href="https://www.powershellgallery.com/packages/PwshSpectreConsole"><img class="not-content" src="https://img.shields.io/powershellgallery/v/PwshSpectreConsole?&color=%238acc00" /></a>
<a class="not-content" href="https://www.powershellgallery.com/packages/PwshSpectreConsole"><img class="not-content" src="https://img.shields.io/powershellgallery/dt/PwshSpectreConsole?&color=%238acc00" /></a>
<a class="not-content" href="https://github.com/ShaunLawrie/PwshSpectreConsole"><img class="not-content" src="https://img.shields.io/github/stars/ShaunLawrie/PwshSpectreConsole?&color=%238acc00" /></a>


### 👻 Emoji Support and Line Drawing

With the default configuration Windows Terminal and the older console host don't support the full range of Spectre Console features. It will still work but you will find it doesn't look quite like all the examples.  

It will look like this:
![Old terminal setup showing missing rendering features](/withoutsetup.png)

Instead of this:
![New terminal setup showing full rendering features](/withsetup.png)

#### To get the full feature set:

 1. Use Windows Terminal instead of the old console host.
 2. Install a NerdFont, a font with additional visual characters. I use "Cascadia Cove NF" from [https://www.nerdfonts.com/](https://www.nerdfonts.com/)
 3. Enable full unicode by adding the following as the **FIRST LINE** in your `$PROFILE` file:

    ```powershell
    $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
    ```

    Your profile file can be located by typing `$PROFILE` in your terminal, the path will be similar to `C:\Users\shaun\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`. Your profile is loaded every time you open a terminal session so you can put other config in there too like your own custom functions and aliases.

For more details see the [instructions on the official Spectre Console site to configure Windows Terminal for full Unicode and Emoji support](https://spectreconsole.net/best-practices#configuring-the-windows-terminal-for-unicode-and-emoji-support).  
