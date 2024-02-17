using namespace Spectre.Console

function Start-AnsiConsoleStatus {
    param (
        [Parameter(Mandatory)]
        [string] $Title,
        [Parameter(Mandatory)]
        [Spinner] $Spinner,
        [Parameter(Mandatory)]
        [Style] $SpinnerStyle,
        [Parameter(Mandatory)]
        [scriptblock] $ScriptBlock
    )
    $resultVariableName = "AnsiConsoleStatusResult-$([guid]::NewGuid())"
    New-Variable -Name $resultVariableName -Scope "Script"
    [AnsiConsole]::Status().Start($Title, {
        param (
            $ctx
        )
        $ctx.Spinner = $Spinner
        $ctx.SpinnerStyle = $SpinnerStyle
        Set-Variable -Name $resultVariableName -Value (& $ScriptBlock $ctx) -Scope "Script"
    })
    return Get-Variable -Name $resultVariableName -ValueOnly
}
