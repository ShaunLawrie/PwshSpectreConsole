using namespace Spectre.Console

# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [AnsiConsoleExtensions]::Markup([AnsiConsole]::Console, $Message)
}

function Write-SpectreHostInternalMarkupLine {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [AnsiConsoleExtensions]::MarkupLine([AnsiConsole]::Console, $Message)
}