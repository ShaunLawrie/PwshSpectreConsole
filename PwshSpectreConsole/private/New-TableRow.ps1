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
        # simplified, should be faster.
        $detectVT = '\x1b'
        $rows = foreach ($cell in $Entry.psobject.Properties) {
            if ([String]::IsNullOrEmpty($cell.Value)) {
                New-TableCell @opts
                continue
            }
            if ($cell.value -match $detectVT) {
                if ($FormatFound) {
                    # we are dealing with an object that has VT codes and a formatdata entry.
                    # this returns a spectre.console.text/markup object with the VT codes applied.
                    ConvertTo-SpectreDecoration -String $cell.Value @opts
                    continue
                }
                else {
                    # we are dealing with an object that has VT codes but no formatdata entry.
                    # this returns a string with the VT codes stripped.
                    # we could pass it to ConvertTo-SpectreDecoration, should we?
                    # note if multiple colors are used it will only use the last color.
                    # better to use Markup to manually add colors.
                    Write-Debug "VT codes detected, but no formatdata entry. stripping VT codes, preferred method of manually adding colors is markup"
                    New-TableCell -String ([System.Management.Automation.Host.PSHostUserInterface]::GetOutputString($cell.Value, $false)) @opts
                    # ConvertTo-SpectreDecoration -String $cell.Value @opts
                    continue
                }
            }
            New-TableCell -String $cell.Value @opts
        }
        return $rows
    }
}
