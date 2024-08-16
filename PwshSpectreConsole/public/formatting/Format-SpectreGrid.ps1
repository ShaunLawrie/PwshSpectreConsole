using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreGrid {
    <#
    .SYNOPSIS
    TODO - Add synopsis

    .DESCRIPTION
    TODO - Add description
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreGrid")]
    # two parameter sets, one for padding evenly and one for specifing tlbr separately
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [GridRowTransformationAttribute()]
        [object]$Data,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Justify = 'Left',
        [int] $Width
    )

    begin {
        $grid = [Spectre.Console.Grid]::new()
        $columnsSet = $false
        if ($Width) {
            $grid.Width = $Width
        }
        $grid.Alignment = [Spectre.Console.Justify]::$Justify
        $grid = $grid.AddColumn()
    }

    process {
        if ($Data -is [array]) {
            foreach ($row in $Data) {
                if (!$columnsSet) {
                    0..($row.Count() - 1) | ForEach-Object {
                        $grid = $grid.AddColumn()
                    }
                    $columnsSet = $true
                }
                $grid = $grid.AddRow($row.ToGridRow())
            }
        } else {
            if (!$columnsSet) {
                0..($row.Count() - 1) | ForEach-Object {
                    $grid = $grid.AddColumn()
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
