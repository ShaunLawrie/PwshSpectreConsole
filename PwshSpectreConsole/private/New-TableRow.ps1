function New-TableRow {
    param(
        [Parameter(Mandatory)]
        [Object] $Entry,
        [Color] $Color = [Color]::Default,
        [Switch] $AllowMarkup,
        [Switch] $Scalar
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $opts = @{
        AllowMarkup = $AllowMarkup
    }
    if ($scalar) {
        New-TableCell -String $Entry -Color $Color @opts
    } else {
        # simplified, should be faster.
        $detectVT = '\x1b'
        $rows = foreach ($cell in $Entry) {
            if ([String]::IsNullOrEmpty($cell)) {
                New-TableCell -Color $Color @opts
                continue
            }
            if ($cell -match $detectVT) {
                ConvertTo-SpectreDecoration -String $cell @opts
                continue
            }
            New-TableCell -String $cell -Color $Color @opts
        }
        return $rows
    }
}
