using namespace Spectre.Console

function New-TableCell {
    [cmdletbinding()]
    param(
        [Object] $String,
        [Switch] $AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ([String]::IsNullOrEmpty($String)) {
        if ($AllowMarkup) {
            return [Markup]::new(' ')
        }
        return [Text]::new(' ')
    }
    if (-Not [String]::IsNullOrEmpty($String.ToString())) {
        if ($AllowMarkup) {
            Write-Debug "New-TableCell ToString(), Markup, $($String.ToString())"
            return [Markup]::new($String.ToString())
        }
        Write-Debug "New-TableCell ToString(), Text, $($String.ToString())"
        return [Text]::new($String.ToString())
    }
    # just coerce to string.
    if ($AllowMarkup) {
        Write-Debug "New-TableCell [String], markup, $([String]$String)"
        return [Markup]::new([String]$String)
    }
    Write-Debug "New-TableCell [String], Text, $([String]$String)"
    return [Text]::new([String]$String)
}
