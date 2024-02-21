using namespace Spectre.Console

function New-TableCell {
    [cmdletbinding()]
    param(
        [Object] $String,
        [Color] $Color = [Color]::Default,
        [Switch] $AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ([String]::IsNullOrEmpty($String)) {
        if ($AllowMarkup) {
            return [Markup]::new(' ', [Style]::new($Color))
        }
        return [Text]::new(' ', [Style]::new($Color))
    }
    if (-Not [String]::IsNullOrEmpty($String.ToString())) {
        if ($AllowMarkup) {
            Write-Debug "New-TableCell ToString(), Markup, $($String.ToString())"
            return [Markup]::new($String.ToString(), [Style]::new($Color))
        }
        Write-Debug "New-TableCell ToString(), Text, $($String.ToString())"
        return [Text]::new($String.ToString(), [Style]::new($Color))
    }
    # just coerce to string.
    if ($AllowMarkup) {
        Write-Debug "New-TableCell [String], markup, $([String]$String)"
        return [Markup]::new([String]$String, [Style]::new($Color))
    }
    Write-Debug "New-TableCell [String], Text, $([String]$String)"
    return [Text]::new([String]$String, [Style]::new($Color))
}
