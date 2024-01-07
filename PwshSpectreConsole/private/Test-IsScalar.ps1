function Test-IsScalar {
    [CmdletBinding()]
    param (
        $Value
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ($Value -is [System.Collections.IEnumerable] -and $Value -isnot [string]) {
        $firstItem = $Value | Select-Object -First 1
        return $firstItem -is [System.ValueType] -or $firstItem -is [System.String]
    } else {
        return $Value -is [System.ValueType] -or $Value -is [System.String]
    }
}
