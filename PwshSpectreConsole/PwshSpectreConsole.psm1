using module ".\private\completions\Completers.psm1"

$script:AccentColor = [Spectre.Console.Color]::Blue
$script:DefaultValueColor = [Spectre.Console.Color]::Grey
$script:DefaultTableHeaderColor = [Spectre.Console.Color]::Default
$script:DefaultTableTextColor = [Spectre.Console.Color]::Default

# For widgets that can be streamed to the console as raw text, prompts/progress widgets do not use this.
# This allows the terminal to process them as text so they can be dumped like:
# PS> $widget = "Hello, World!" | Format-SpectrePanel -Title "My Panel" -Color Blue -Expand
# PS> $widget # uses the default powershell console writer
# PS> $widget > file.txt # redirects as string data to file
# PS> $widget | Out-SpectreHost # uses a dedicated console writer that doesn't pad the object like the default formatter
$script:SpectreConsoleWriter = [System.IO.StringWriter]::new()
$script:SpectreConsoleOutput = [Spectre.Console.AnsiConsoleOutput]::new($script:SpectreConsoleWriter)
$script:SpectreConsoleSettings = [Spectre.Console.AnsiConsoleSettings]::new()
$script:SpectreConsoleSettings.Out = $script:SpectreConsoleOutput
$script:SpectreConsole = [Spectre.Console.AnsiConsole]::Create($script:SpectreConsoleSettings)

foreach ($directory in @('private', 'public')) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }
}

$script:SpectreProfile = Get-SpectreProfile
if ($script:SpectreProfile.Unicode -eq $true -or $env:IgnoreSpectreConsoleEncoding) {
    return $script:SpectreConsole
}

if ($env:IgnoreSpectreEncoding -eq $true) {
    return
}

@"
[white]Your terminal host is currently using encoding '$($SpectreProfile.Encoding)' which limits Spectre Console functionality.

To enable UTF-8 output in your terminal, add the following line at the top of your PowerShell `$PROFILE file and restart the terminal:
[Orange1 on Grey15]$('$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()' | Get-SpectreEscapedText)[/]

If you don't want to enable UTF-8, you can suppress this warning with the environment variable [Orange1 on Grey15]`$env:IgnoreSpectreEncoding = `$true[/] instead.

For more details see:
 - https://github.com/ShaunLawrie/PwshSpectreConsole/issues/46
 - https://spectreconsole.net/best-practices#configuring-the-windows-terminal-for-unicode-and-emoji-support
 - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles[/]
"@ | Format-SpectrePanel -Title "[Orange1] PwshSpectreConsole Warning [/]" -Color OrangeRed1 -Expand | Out-Host