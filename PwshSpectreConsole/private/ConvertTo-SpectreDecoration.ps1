using namespace Spectre.Console

function ConvertTo-SpectreDecoration {
    param(
        [Parameter(Mandatory)]
        [String]$String,
        [switch]$AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if (-Not ('PwshSpectreConsole.VTCodes.Parser' -as [type])) {
        Add-PwshSpectreConsole.VTCodes
    }
    $lookup = [PwshSpectreConsole.VTCodes.Parser]::Parse($String)
    $ht = @{
        decoration = [Decoration]::None
        fg         = [Color]::Default
        bg         = [Color]::Default
    }
    foreach ($item in $lookup) {
        # Write-Debug "Type: $($item.type) Value: $($item.value) Position: $($item.position) Color: $($item.color)"
        if ($item.value -eq 'None') {
            continue
        }
        $conversion = switch ($item.type) {
            '4bit' {
                if ($item.value -gt 0 -and $item.value -le 15) {
                    [Color]::FromConsoleColor($item.value)
                }
                else {
                    # spectre doesn't appear to have a way to convert from 4bit.
                    # e.g all $PSStyle colors 30-37, 40-47 and 90-97, 100-107
                    # this will return the closest color in 8bit.
                    [Color]::FromConsoleColor((ConvertFrom-ConsoleColor $item.value))
                }
            }
            '8bit' {
                [Color]::FromInt32($item.value)
            }
            '24bit' {
                [Color]::new($item.value.Red, $item.value.Green, $item.value.Blue)
            }
            'decoration' {
                [Decoration]::Parse([Decoration], $item.Value, $true)
            }
        }
        if ($item.type -eq 'decoration') {
            $ht.decoration = $conversion
        }
        if ($item.position -eq 'foreground') {
            $ht.fg = $conversion
        }
        elseif ($item.position -eq 'background') {
            $ht.bg = $conversion
        }
    }
    $String = [System.Management.Automation.Host.PSHostUserInterface]::GetOutputString($String, $false)
    Write-Debug "Clean: '$String' deco: '$($ht.decoration)' fg: '$($ht.fg)' bg: '$($ht.bg)'"
    if ($AllowMarkup) {
        return [Markup]::new($String, [Style]::new($ht.fg, $ht.bg, $ht.decoration))
    }
    return [Text]::new($String, [Style]::new($ht.fg, $ht.bg, $ht.decoration))
}
