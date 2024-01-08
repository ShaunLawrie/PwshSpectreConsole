function New-TableRow {
    param(
        $Entry,
        [Switch] $FormatFound,
        [Switch] $PropertiesSelected,
        [Switch] $AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $opts = @{}
    if ($AllowMarkup) {
        $opts.AllowMarkup = $true
    }
    if ((-Not $FormatFound -or -Not $PropertiesSelected) -And ($scalarDetected -eq $true)) {
        New-TableCell -String $Entry @opts
    }
    else {
        $strip = '\x1B\[[0-?]*[ -/]*[@-~]'
        $rows = foreach ($cell in $Entry.psobject.Properties) {
            if ([String]::IsNullOrEmpty($cell.Value)) {
                New-TableCell @opts
                continue
            }
            if ($FormatFound -And $cell.value -match $strip) {
                # we are dealing with an object that has VT codes and a formatdata entry.
                # this returns a spectre.console.text/markup object with the VT codes applied.
                ConvertTo-SpectreDecoration -String $cell.Value @opts
                continue
            }
            New-TableCell -String $cell.Value @opts
        }
        return $rows
    }
}
