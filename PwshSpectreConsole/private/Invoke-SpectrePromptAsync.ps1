
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
        $Prompt,
        [int] $TimeoutSeconds
    )

    $timeout = $null
    if ($TimeoutSeconds) {
        $timeout = (Get-Date).AddSeconds($TimeoutSeconds)
        Write-SpectreHost "[$script:DefaultValueColor]This prompt times out in $TimeoutSeconds seconds...[/]`n"
    }

    $cts = [System.Threading.CancellationTokenSource]::new()
    try {
        $task = $Prompt.ShowAsync([Spectre.Console.AnsiConsole]::Console, $cts.Token)
        while (-not $task.AsyncWaitHandle.WaitOne(200)) {
            # Waiting for the async task this way allows ctrl-c interrupts to continue to work within the single-threaded PowerShell world
            if ($null -ne $timeout -and (Get-Date) -ge $timeout) {
                $cts.Cancel()
                Write-SpectreHost "`n`n[$script:DefaultValueColor]Prompt timed out[/]"
            }
        }
        if (!$task.IsCanceled) {
            return $task.GetAwaiter().GetResult()
        }
    } finally {
        $cts.Cancel()
        $task.Dispose()
    }
}