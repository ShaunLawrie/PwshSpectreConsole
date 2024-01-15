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
        $detectAnsi = '\x1B' # simplified, should be faster.
        $rows = foreach ($cell in $Entry.psobject.Properties) {
            if ([String]::IsNullOrEmpty($cell.Value)) {
                New-TableCell @opts
                continue
            }
            if ($FormatFound -And $cell.value -match $detectAnsi) {
                # do we require a formatdata entry?
                # if ($cell.value -match $detectAnsi) {
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
