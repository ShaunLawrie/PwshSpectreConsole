using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreGrid {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectregrid/')]
    <#
    .SYNOPSIS
    Formats data into a Spectre Console grid.

    .DESCRIPTION
    Formats data into a Spectre Console grid. The grid can be used to display data in a tabular format but it's not as flexible as the Layout widget.  
    See https://spectreconsole.net/widgets/grid for more information.

    .PARAMETER Data
    The data to be displayed in the grid. This can be a list of lists or a list of `New-SpectreGridRow` objects.

    .PARAMETER Width
    The width of the grid. If not specified, the grid width will be automatic.

    .PARAMETER Padding
    The padding to apply to the grid items. The default is 1.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to display a grid of rows using the Spectre Console module with a list of lists.
    Format-SpectreGrid -Data @("hello", "I", "am"), @("a", "grid", "of"), @("rows", "using", "spectre")

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to display a grid of rows using the Spectre Console module with a list of `New-SpectreGridRow` objects.
    # The `New-SpectreGridRow` function is used to create the rows when you want to avoid array collapsing in PowerShell turning your rows into a single array of columns.
    $rows = 4
    $cols = 6
    
    $gridRows = @()
    for ($row = 1; $row -le $rows; $row++) {
        $columns = @()
        for ($col = 1; $col -le $cols; $col++) {
            $columns += "Row $row, Col $col" | Format-SpectrePanel
        }
        $gridRows += New-SpectreGridRow $columns
    }
    
    $gridRows | Format-SpectreGrid
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreGrid")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [GridRowTransformationAttribute()]
        [object]$Data,
        [int] $Width,
        [int] $Padding = 1
    )

    begin {
        $grid = [Spectre.Console.Grid]::new()
        $columnsSet = $false
        if ($Width) {
            $grid.Width = $Width
        }
        $grid.Alignment = [Spectre.Console.Justify]::$Justify
        $col = [Spectre.Console.GridColumn]::new()
        $grid = $grid.AddColumn()
    }

    process {
        if ($Data -is [array]) {
            foreach ($row in $Data) {
                if (!$columnsSet) {
                    0..($row.Count() - 1) | ForEach-Object {
                        $grid = $grid.AddColumn($col)
                    }
                    $columnsSet = $true
                }
                $grid = $grid.AddRow($row.ToGridRow())
            }
        } else {
            if (!$columnsSet) {
                0..($row.Count() - 1) | ForEach-Object {
                    $grid = $grid.AddColumn($col)
                }
                $columnsSet = $true
            }
            $grid = $grid.AddRow($Data.ToGridRow())
        }
    }
    
    end {
        return $grid
    }
}
