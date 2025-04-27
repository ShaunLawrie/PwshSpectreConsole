function Open-PwshSpectreConsoleHelp {
    <#
        .SYNOPSIS
            Opens the help page for PwshSpectreConsole in the default browser.
        .DESCRIPTION
            This function opens the help page for PwshSpectreConsole in the default browser.
        .EXAMPLE
            # **Example 1**
            # Open the help page for PwshSpectreConsole in the default browser.
            Open-PwshSpectreConsoleHelp
        .LINK
            https://pwshspectreconsole.com/guides/get-started/
    #>
    [Reflection.AssemblyMetadata("title", "Open-PwshSpectreConsoleHelp")]
    param()

    $online = "https://pwshspectreconsole.com/guides/get-started/"
    
    Write-SpectreHost "[Grey69]Opening the [white link=$online]online help page[/] for PwshSpectreConsole in your default browser...[/]"

    try {
        if ($IsWindows) {
            Start-Process $online -ErrorAction Stop -Wait
            return
        } elseif ($IsLinux -and (Get-Command -Name "xdg-open" -ErrorAction SilentlyContinue)) {
            Start-Process "xdg-open" -ArgumentList $online -ErrorAction Stop
            return
        } elseif ($IsMacOS) {
            Start-Process "open" -ArgumentList $online -ErrorAction Stop -Wait
            return
        }   
    } catch {
        Write-SpectreHost "[DarkOrange]Unable to open your browser :crying_face:[/]"
    }

    Write-SpectreHost "[DarkOrange]View [white link]$online[/] in your browser to view online help for this module.[/]"
}