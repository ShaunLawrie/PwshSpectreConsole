function Add-PwshSpectreConsole.VTCodes {
    if (-Not ('PwshSpectreConsole.VTCodes.Parser' -as [type])) {
        Add-Type -Path (Join-Path $PSScriptRoot classes 'PwshSpectreConsole.VTCodes.cs')
    }
}
