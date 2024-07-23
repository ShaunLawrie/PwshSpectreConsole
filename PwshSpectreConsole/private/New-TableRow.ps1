function New-TableRow {
    param(
        [Parameter(Mandatory)]
        [Object] $Entry,
        [Color] $Color = [Color]::Default,
        [Switch] $AllowMarkup,
        [Switch] $Scalar,
        [hashtable] $Renderables
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    $opts = @{
        AllowMarkup = $AllowMarkup
    }
    if ($scalar) {
        # Swap spectre renderable objects with the raw object
        $name = $Entry.ToString()
        if ($name.StartsWith("RENDERABLE__")) {
            $Entry = $renderables[$name]
        }
        New-TableCell -CellData $Entry -Color $Color @opts
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
            # Swap spectre renderable objects with the raw spectre renderable object
            $name = $cell.ToString()
            if ($name.StartsWith("RENDERABLE__")) {
                $cell = $renderables[$name]
            }
            New-TableCell -CellData $cell -Color $Color @opts
        }
        return $rows
    }
}
