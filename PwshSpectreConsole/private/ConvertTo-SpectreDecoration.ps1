function ConvertTo-SpectreDecoration {
    param(
        [Parameter(Mandatory)]
        [String]$String
    )
    if (-Not ('PwshSpectreConsole.VTCodes.Parser' -as [type])) {
        Add-PwshSpectreConsole.VTCodes
    }
    Write-Debug "ANSI String: $String '$($String -replace '\x1B','e')'"
    $lookup = [PwshSpectreConsole.VTCodes.Parser]::Parse($String)
    $ht = @{}
    foreach ($item in $lookup) {
        if ($item.value -eq 'reset') {
            continue
        }
        $conversion = switch ($item.type) {
            '4bit' {
                if ($item.value -gt 0 -and $item.value -le 15) {
                    [Spectre.Console.Color]::FromConsoleColor($item.value)
                }
                else {
                    [Spectre.Console.Color]::FromInt32($item.value)
                }
            }
            '8bit' {
                [Spectre.Console.Color]::FromInt32($item.value)
            }
            '24bit' {
                [Spectre.Console.Color]::new($item.value.Red, $item.value.Green, $item.value.Blue)
            }
            'decoration' {
                [Spectre.Console.Decoration]::Parse([Spectre.Console.Decoration], $item.Value, $true)
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
    $String = $String -replace '\x1B\[[0-?]*[ -/]*[@-~]'
    Write-Debug "Clean: '$String' deco: '$($ht.decoration)' fg: '$($ht.fg)' bg: '$($ht.bg)'"
    [Spectre.Console.Text]::new($String,[Spectre.Console.Style]::new($ht.fg,$ht.bg,$ht.decoration))
}
