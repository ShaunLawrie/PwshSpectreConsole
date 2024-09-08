using module ".\completions\Completers.psm1"

# Functions required for unit testing write-spectrehost
function Write-SpectreHostInternalMarkup {
    param (
        [string] $Message,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Justify = "Left",
        [switch] $NoNewline,
        [switch] $PassThru
    )

    # If the message is empty, set it to a space. Spectre Console doesn't like empty strings for this.
    if ($Message -eq "") {
        $Message = " "
    }

    if ($PassThru) {
        # NewLine isn't required for PassThru
        $output = [Spectre.Console.Markup]::new($Message)
        $output.Justification = [Spectre.Console.Justify]::$Justify
        return $output
    }

    if (-not $NoNewline) {
        $Message += "`n"
    }

    $output = [Spectre.Console.Markup]::new($Message)
    $output.Justification = [Spectre.Console.Justify]::$Justify

    [Spectre.Console.AnsiConsole]::Write($output)
}