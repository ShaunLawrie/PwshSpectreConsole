
# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [Spectre.Console.AnsiConsoleExtensions]::Markup([Spectre.Console.AnsiConsole]::Console, $Message)
}

function Write-SpectreHostInternalMarkupLine {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [Spectre.Console.AnsiConsoleExtensions]::MarkupLine([Spectre.Console.AnsiConsole]::Console, $Message)
}