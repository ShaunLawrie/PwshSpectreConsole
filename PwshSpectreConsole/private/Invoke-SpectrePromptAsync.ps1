using namespace Spectre.Console

function Invoke-SpectrePromptAsync {
    <#
    .SYNOPSIS
    Shows a Spectre.Console prompt.

    .DESCRIPTION
    This function shows a Spectre.Console prompt "asynchronously" in PowerShell by faking the async call. By allowing the prompt to run asynchronously in the background and polling for its completion, it allows ctrl-c interrupts to continue to work within the single-threaded PowerShell world.

    .PARAMETER Prompt
    The Spectre.Console prompt to show.

    .EXAMPLE
    $result = Invoke-SpectrePromptAsync $prompt
    #>
    param (
        [Parameter(Mandatory)]
        $Prompt
    )
    $cts = [System.Threading.CancellationTokenSource]::new()
    try {
        $task = $Prompt.ShowAsync([AnsiConsole]::Console, $cts.Token)
        while (-not $task.AsyncWaitHandle.WaitOne(200)) {
            # Waiting for the async task this way allows ctrl-c interrupts to continue to work within the single-threaded PowerShell world
        }
        return $task.GetAwaiter().GetResult()
    } finally {
        $cts.Cancel()
        $task.Dispose()
    }
}