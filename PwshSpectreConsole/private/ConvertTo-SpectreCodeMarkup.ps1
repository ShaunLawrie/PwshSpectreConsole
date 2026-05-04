<#
.SYNOPSIS
    Converts a code string to a Spectre.Console Markup string with syntax highlighting.
.DESCRIPTION
    For PowerShell code (ps1/pwsh/powershell/posh), tokenises via the PS language parser
    and delegates colour lookup to Get-TokenColor (defined in PwshSyntaxHighlight.ps1).
    For all other languages, returns the bracket-escaped plain text so it renders safely
    without colour.
#>
function ConvertTo-SpectreCodeMarkup {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Code,
        [string]$Language = '',
        [ValidateSet('Github', 'Matrix')]
        [string]$Theme = 'Github'
    )

    # Escape Spectre markup special chars so raw brackets don't break the parser
    $escapedPlain = $Code -replace '\[', '[[' -replace '\]', ']]'

    if ($Language -notin @('powershell', 'ps1', 'pwsh', 'posh')) {
        return $escapedPlain
    }

    # PowerShell syntax highlighting via the built-in language parser
    $tokens = $null
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$tokens, [ref]$errors)

    if (-not $tokens) { return $escapedPlain }

    $sb   = [System.Text.StringBuilder]::new()
    $last = 0

    foreach ($token in $tokens) {
        if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::EndOfInput) { break }

        $start = $token.Extent.StartOffset
        $end   = $token.Extent.EndOffset

        # Literal gap text between previous token end and this token start
        if ($start -gt $last) {
            $gap = $Code.Substring($last, $start - $last)
            [void]$sb.Append(($gap -replace '\[', '[[' -replace '\]', ']]'))
        }

        $raw = $Code.Substring($start, $end - $start)
        $esc = $raw -replace '\[', '[[' -replace '\]', ']]'

        # Delegate colour lookup to the shared theme-aware function in PwshSyntaxHighlight.ps1
        $rgb = Get-TokenColor -Kind $token.Kind -TokenFlags $token.TokenFlags -Theme $Theme
        $hex = '#{0:x2}{1:x2}{2:x2}' -f $rgb.R, $rgb.G, $rgb.B
        [void]$sb.Append("[$hex]$esc[/]")

        $last = $end
    }

    # Any trailing content after the final token
    if ($last -lt $Code.Length) {
        $tail = $Code.Substring($last)
        [void]$sb.Append(($tail -replace '\[', '[[' -replace '\]', ']]'))
    }

    return $sb.ToString()
}
