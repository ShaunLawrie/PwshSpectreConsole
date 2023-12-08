using module "..\..\private\completions\Completers.psm1"

function Invoke-SpectreCommandWithStatus {
    <#
    .SYNOPSIS
    Invokes a script block with a Spectre status spinner.

    .DESCRIPTION
    This function starts a Spectre status spinner with the specified title and spinner type, and invokes the specified script block. The spinner will continue to spin until the script block completes.

    .PARAMETER ScriptBlock
    The script block to invoke.

    .PARAMETER Spinner
    The type of spinner to display. Valid values are "dots", "dots2", "dots3", "dots4", "dots5", "dots6", "dots7", "dots8", "dots9", "dots10", "dots11", "dots12", "line", "line2", "pipe", "simpleDots", "simpleDotsScrolling", "star", "star2", "flip", "hamburger", "growVertical", "growHorizontal", "balloon", "balloon2", "noise", "bounce", "boxBounce", "boxBounce2", "triangle", "arc", "circle", "squareCorners", "circleQuarters", "circleHalves", "squish", "toggle", "toggle2", "toggle3", "toggle4", "toggle5", "toggle6", "toggle7", "toggle8", "toggle9", "toggle10", "toggle11", "toggle12", "toggle13", "arrow", "arrow2", "arrow3", "bouncingBar", "bouncingBall", "smiley", "monkey", "hearts", "clock", "earth", "moon", "runner", "pong", "shark", "dqpb", "weather", "christmas", "grenade", "point", "layer", "betaWave", "pulse", "noise2", "gradient", "christmasTree", "santa", "box", "simpleDotsDown", "ballotBox", "checkbox", "radioButton", "spinner", "lineSpinner", "lineSpinner2", "pipeSpinner", "simpleDotsSpinner", "ballSpinner", "balloonSpinner", "noiseSpinner", "bouncingBarSpinner", "smileySpinner", "monkeySpinner", "heartsSpinner", "clockSpinner", "earthSpinner", "moonSpinner", "auto", "random".

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
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup()
    )
    $splat = @{
        Title = $Title
        Spinner = [Spectre.Console.Spinner+Known]::$Spinner
        SpinnerStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
        ScriptBlock = $ScriptBlock
    }
    Start-AnsiConsoleStatus @splat
}
