function Test-IsScalar {
    [CmdletBinding()]
    param(
        $Value
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $Value = $Value | Select-Object -First 1
    }
    return $Value -is [System.ValueType] -or $Value -is [System.String]
}
