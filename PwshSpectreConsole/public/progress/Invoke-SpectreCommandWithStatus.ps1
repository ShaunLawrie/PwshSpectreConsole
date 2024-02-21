using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Invoke-SpectreCommandWithStatus {
    <#
    .SYNOPSIS
    Invokes a script block with a Spectre status spinner.

    .DESCRIPTION
    This function starts a Spectre status spinner with the specified title and spinner type, and invokes the specified script block. The spinner will continue to spin until the script block completes.

    .PARAMETER ScriptBlock
    The script block to invoke.

    .PARAMETER Spinner
    The type of spinner to display.

    .PARAMETER Title
    The title to display above the spinner.

    .PARAMETER Color
    The color of the spinner. Valid values can be found with Get-SpectreDemoColors.

    .EXAMPLE
    # Starts a Spectre status spinner with the "dots" spinner type, a yellow color, and the title "Waiting for process to complete". The spinner will continue to spin for 5 seconds.
    Invoke-SpectreCommandWithStatus -ScriptBlock { Start-Sleep -Seconds 5 } -Spinner dots -Title "Waiting for process to complete" -Color yellow
    #>
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithStatus")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,
        [ValidateSet([SpectreConsoleSpinner],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Spinner = "Dots",
        [Parameter(Mandatory)]
        [string] $Title,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor
    )
    $splat = @{
        Title = $Title
        Spinner = [Spinner+Known]::$Spinner
        SpinnerStyle = [Style]::new($Color)
        ScriptBlock = $ScriptBlock
    }
    Start-AnsiConsoleStatus @splat
}
