using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

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
    # **Example 1**
    # This example demonstrates how to show a spinner while doing some work. Write-SpectreHost is used to update the host with progress without breaking the spinner animation.
    $result = Invoke-SpectreCommandWithStatus -Spinner "Dots2" -Title "Showing a spinner..." -ScriptBlock {
        # Write updates to the host using Write-SpectreHost
        Start-Sleep -Seconds 1
        Write-SpectreHost "`n[grey]LOG:[/] Doing some work      "
        Start-Sleep -Seconds 1
        Write-SpectreHost "`n[grey]LOG:[/] Doing some more work "
        Start-Sleep -Seconds 1
        Write-SpectreHost "`n[grey]LOG:[/] Done                 "
        Start-Sleep -Seconds 1
        Write-SpectreHost " "
        return "Some result"
    }
    Write-SpectreHost "Result: $result"
    #>
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreCommandWithStatus")]
    param (
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock,
        [ValidateSet([SpectreConsoleSpinner], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Spinner = "Dots",
        [Parameter(Mandatory)]
        [string] $Title,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor
    )
    $splat = @{
        Title        = $Title
        Spinner      = [Spectre.Console.Spinner+Known]::$Spinner
        SpinnerStyle = [Spectre.Console.Style]::new($Color)
        ScriptBlock  = $ScriptBlock
    }
    Start-AnsiConsoleStatus @splat
}
