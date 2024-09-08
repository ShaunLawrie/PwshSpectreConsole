class SpectreGridRow {

    hidden [Spectre.Console.Rendering.Renderable[]] $InternalColumns = @()

    [int] Count() {
        return $this.InternalColumns.Count
    }

    [Spectre.Console.GridRow] ToGridRow() {
        return [Spectre.Console.GridRow]::new([Spectre.Console.Rendering.Renderable[]]$this.InternalColumns)
    }

    SpectreGridRow([object[]] $Columns) {
        foreach ($column in $Columns) {
            if ($column -is [Spectre.Console.Rendering.Renderable]) {
                $this.InternalColumns += $column
            } elseif ($column -like "*[/]*") {
                $this.InternalColumns += [Spectre.Console.Markup]::new($column)
            } else {
                $this.InternalColumns += [Spectre.Console.Text]::new($column.ToString().TrimEnd())
            }
        }
    }
}