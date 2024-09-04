using module ".\completions\Completers.psm1"

# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [Parameter(Mandatory)]
        [string] $Message,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Justify = "Left",
        [switch] $NoNewline,
        [switch] $PassThru
    )

    # Add a newline character to the end of the message if NoNewline is not specified
    if (-not $NoNewline) {
        $Message = $Message.TrimEnd() + "`n"
    }

    $output = [Spectre.Console.Markup]::new($Message)
    $output.Justification = [Spectre.Console.Justify]::$Justify
    if ($PassThru) {
        return $output
    }
    [Spectre.Console.AnsiConsole]::Write($output)
}