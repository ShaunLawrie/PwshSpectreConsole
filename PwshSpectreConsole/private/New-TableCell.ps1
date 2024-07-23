using namespace Spectre.Console

function New-TableCell {
    [cmdletbinding()]
    param(
        [Object] $CellData,
        [Color] $Color = [Color]::Default,
        [Switch] $AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"

    # Spectre console already knows how to format its own renderables, this allows embedding spectre widgets inside table cells
    if ($CellData -is [Spectre.Console.Rendering.Renderable]) {
        return $CellData
    }

    if ([String]::IsNullOrEmpty($CellData)) {
        if ($AllowMarkup) {
            return [Markup]::new(' ', [Style]::new($Color))
        }
        return [Text]::new(' ', [Style]::new($Color))
    }
    if (-Not [String]::IsNullOrEmpty($CellData.ToString())) {
        if ($AllowMarkup) {
            Write-Debug "New-TableCell ToString(), Markup, $($CellData.ToString())"
            return [Markup]::new($CellData.ToString(), [Style]::new($Color))
        }
        Write-Debug "New-TableCell ToString(), Text, $($CellData.ToString())"
        return [Text]::new($CellData.ToString(), [Style]::new($Color))
    }
    # just coerce to string.
    if ($AllowMarkup) {
        Write-Debug "New-TableCell [String], markup, $([String]$CellData)"
        return [Markup]::new([String]$CellData, [Style]::new($Color))
    }
    Write-Debug "New-TableCell [String], Text, $([String]$CellData)"
    return [Text]::new([String]$CellData, [Style]::new($Color))
}
