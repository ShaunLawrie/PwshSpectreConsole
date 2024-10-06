function Get-TerminalCapabilities {
    <#
    primary device attributes
    we can detect sixel support.. if we wanted to.
    https://github.com/microsoft/terminal/blob/main/src/terminal/parser/InputStateMachineEngine.hpp#L52-L76
    https://vt100.net/docs/vt510-rm/chapter4.html
    https://gist.github.com/Jaykul/f9aac8753b5fe39fa24a96bf7f4dc6b7
    #>
    [CmdletBinding()]
    param()
    $lookup = @{
        1  = 'Columns132'
        2  = 'PrinterPort'
        4  = 'Sixel'
        6  = 'SelectiveErase'
        7  = 'SoftCharacterSet (DRCS)'
        8  = 'UserDefinedKeys (UDK)'
        9  = 'NationalReplacementCharacterSets (NRCS)'
        12 = 'SerboCroatianCharacterSet (SCS)'
        14 = 'EightBitInterfaceArchitecture'
        15 = 'TechnicalCharacterSet'
        18 = 'WindowingCapability'
        19 = 'Sessions'
        21 = 'HorizontalScrolling'
        22 = 'Color'
        23 = 'GreekCharacterSet'
        24 = 'TurkishCharacterSet'
        28 = 'RectangularAreaOperations'
        32 = 'TextMacros'
        42 = 'Latin2CharacterSet'
        44 = 'PCTerm'
        45 = 'Softkeymapping'
        46 = 'ASCII emulation'
        61 = 'PS1 (WT?)' # havnt found a reference for this
        64 = 'VT100'
        65 = 'VT520'
    }
    <#
    below is workaround for a bug in WT.. i think?.. replace when fixed.
    [console]::Write([char]27 + '[c')
    $response = while ([console]::KeyAvailable) {
        $char = [console]::ReadKey($true).KeyChar
        $char
        if ($char -eq 'c') {
            break
        }
    }
    #>
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    [console]::Write([char]27 + '[c')
    $response = while ($true) {
            $char = [console]::ReadKey($true).KeyChar
            $char
            if ($char -eq 'c' -or $timer.Elapsed.TotalSeconds -gt 1) {
                break
            }
        }
    $timer = $null
    $response = -join ($response -replace [char]27, [char]9243)
    $DA1 = [ordered]@{}
    ([int[]] $Modes = $response -split ';' -replace '\D') | Where-Object { $_ -lt 60 } | ForEach-Object {
        if ($lookup.ContainsKey($_)) {
            $DA1[$lookup[$_]] = $true
        }
        else {
            $DA1["Unknown mode $_"] = $true
        }
    }
    $DA1['Raw'] = $response
    [PSCustomObject]$DA1
}
