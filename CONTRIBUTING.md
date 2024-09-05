# Contributing

👋🏻 Hi, and thank you for getting as far as reading the contributing guide!

I'm thrilled that you're interested in contributing to this project. Your contributions are valuable and help make the module even better.

## How to Contribute

### 🐛 Reporting Bugs

If you find a bug, please raise an issue on the GitHub repo. Please include as much detail as possible, including the version of the module you're using, the version of PowerShell, and the OS you're running on.

### ✨ Suggesting Enhancements

If you have an idea for an enhancement, please raise an issue on the GitHub repo as a starting point. This allows us to discuss a potential solution. I've found that discussing the enhancement before writing code can save a lot of time and effort.

### 💻 Development Guidelines

These are guidelines not rules, you can do whatever you want to make things work and open a PR but following these guidelines will make it easier for me to review your PR and get it merged.

1. Fork this repo from the `prerelease` branch. This is where all development is done and pre-release versions are published from. The `main` branch is only used for production releases after the pre-release changes have had some more thorough testing.
2. This is a PowerShell module and I intend on keeping it mostly PowerShell so those familiar with PowerShell but not C# can still contribute. If you're adding a feature that requires a C# class, please raise an issue first so we can discuss the best way to implement it. I'm aware not all features can be implemented in PowerShell and I'm open to adding C# code where necessary.
3. Importing namespaces at the top of the `ps1` scripts is not advised, it makes the code more concise but it removes the ability to easily copy-paste code into a script.
4. All public functions go in the `/PwshSpectreConsole/public` folder. These functions also need to be added to the FunctionsToExport array in the `PwshSpectreConsole.psd1` file to make them accessible to users.
5. All internal functions go in the `/PwshSpectreConsole/private` folder.
6. All functions in the `/PwshSpectreConsole/public` folder should have a comment-based help block at the top of the function. This is used to generate the markdown for the documentation site. See [`Read-SpectreMultiSelection.ps1`](PwshSpectreConsole/public/prompts/Read-SpectreMultiSelection.ps1) for an example. See [documentation help](/PwshSpectreConsole.Docs/README.md) for more information.
7. All public functions should have unit tests in the `/PwshSpectreConsole.Tests` folder. These tests should be written in Pester and should test the function in a variety of scenarios. The tests should be named the same as the function they're testing with `.Tests` appended to the end. e.g. [`Read-SpectreMultiSelection.tests.ps1`](PwshSpectreConsole.Tests/prompts/Read-SpectreMultiSelection.tests.ps1).

## Thanks to Those Who Have Already Contributed

These people are awesome and you should go follow them to keep tabs on all the other awesome stuff they're doing:

- **[@patriksvensson](https://github.com/patriksvensson)**  
  The [Spectre Console](https://spectreconsole.net/) creator. Without the dotnet library this module wouldn't exist.
- **[@dfinke](https://github.com/dfinke)**  
  Doug Finke helped fix some broken table logic in the earliest days of the module yet his biggest contribution has been to my growth as a developer. Thanks for helping me gather the courage to build in the open.
- **[@trackd](https://github.com/trackd)**  
  The table whisperer. Most of the logic for translating between PowerShell objects and the format required by the Spectre Console table widgets has come from their big brain and it's melted mine. They're a crazy-talented PowerShell developer who has helped teach me a lot and their contributions are a big part of the v2 release.
- **[@StartAutomating](https://github.com/StartAutomating)**  
  Thanks for the sponsorship, EZOut and HelpOut modules. HelpOut is used to generate the markdown that powers the [pwshspectreconsole.com](https://pwshspectreconsole.com/reference/formatting/format-spectrebarchart/) documentation site.
- **[@futuremotiondev](https://github.com/futuremotiondev)**, **[@ruckii](https://github.com/ruckii)** and **[@csillikd-messerli](https://github.com/csillikd-messerli)**  
  Thank you for the issues raised and the fixes you've pulled together making this module better.

## Contact Me

If you have any questions, please reach out to me on Twitter [@shaun_lawrie](https://twitter.com/shaun_lawrie).  
You can also find me on Discord in the [PowerShell discord](https://discord.gg/powershell) as `shaunlawrie`.
