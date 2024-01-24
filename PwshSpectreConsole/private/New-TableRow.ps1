function New-TableRow {
    param(
        $Entry,
        [Switch] $AllowMarkup,
        [Switch] $Scalar
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $opts = @{}
    if ($AllowMarkup) {
        $opts.AllowMarkup = $true
    }
    if ($scalar) {
        New-TableCell -String $Entry @opts
    }
    else {
        # simplified, should be faster.
        $detectVT = '\x1b'
        $rows = foreach ($cell in $Entry) {
            if ([String]::IsNullOrEmpty($cell.propertyValue)) {
                New-TableCell @opts
                continue
            }
            if ($cell.propertyValue -match $detectVT) {
                ConvertTo-SpectreDecoration -String $cell.propertyValue @opts
                continue
            }
            New-TableCell -String $cell.propertyValue @opts
        }
        return $rows
    }
}
