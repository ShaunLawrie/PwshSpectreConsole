
function New-TableCell {
    [cmdletbinding()]
    param(
        [Object] $CellData,
        [Spectre.Console.Color] $Color = [Spectre.Console.Color]::Default,
        [Switch] $AllowMarkup
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"

    # Spectre console already knows how to format its own renderables, this allows embedding spectre widgets inside table cells
    if ($CellData -is [Spectre.Console.Rendering.Renderable]) {
        return $CellData
    }

    if ([String]::IsNullOrEmpty($CellData)) {
        if ($AllowMarkup) {
            return [Spectre.Console.Markup]::new(' ', [Spectre.Console.Style]::new($Color))
        }
        return [Spectre.Console.Text]::new(' ', [Spectre.Console.Style]::new($Color))
    }
    if (-Not [String]::IsNullOrEmpty($CellData.ToString())) {
        if ($AllowMarkup) {
            Write-Debug "New-TableCell ToString(), Markup, $($CellData.ToString())"
            return [Spectre.Console.Markup]::new($CellData.ToString(), [Spectre.Console.Style]::new($Color))
        }
        Write-Debug "New-TableCell ToString(), Text, $($CellData.ToString())"
        return [Spectre.Console.Text]::new($CellData.ToString(), [Spectre.Console.Style]::new($Color))
    }
    # just coerce to string.
    if ($AllowMarkup) {
        Write-Debug "New-TableCell [String], markup, $([String]$CellData)"
        return [Spectre.Console.Markup]::new([String]$CellData, [Spectre.Console.Style]::new($Color))
    }
    Write-Debug "New-TableCell [String], Text, $([String]$CellData)"
    return [Spectre.Console.Text]::new([String]$CellData, [Spectre.Console.Style]::new($Color))
}
