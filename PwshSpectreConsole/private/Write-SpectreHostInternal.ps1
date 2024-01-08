# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [Spectre.Console.AnsiConsole]::Markup($Message)
}

function Write-SpectreHostInternalMarkupLine {
    param (
        [Parameter(Mandatory)]
        [string] $Message
    )
    [Spectre.Console.AnsiConsole]::MarkupLine($Message)
}