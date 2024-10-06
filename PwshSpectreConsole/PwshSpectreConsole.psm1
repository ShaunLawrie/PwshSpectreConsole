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
if ($script:SpectreProfile.Encoding -ne 'Unicode (UTF-8)' -and -Not $env:IgnoreSpectreEncoding) {
    $utf8 = '$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()'
    Write-Warning "Spectre.Console is not using UTF-8 encoding, this disables certain functionality, consider adding `n$utf8`nto your profile, to suppress this warning set the environment variable '`$env:IgnoreSpectreEncoding=`$true'"
}
