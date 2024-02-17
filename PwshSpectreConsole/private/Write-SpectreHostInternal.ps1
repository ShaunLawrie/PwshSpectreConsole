using namespace Spectre.Console

# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [AnsiConsole]::Markup($Message)
}

function Write-SpectreHostInternalMarkupLine {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [AnsiConsole]::MarkupLine($Message)
}