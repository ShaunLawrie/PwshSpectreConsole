using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreColumns {
    <#
    .SYNOPSIS
    Renders a collection of renderables in columns to the console.

    .DESCRIPTION
    This function creates a spectre columns widget that renders a collection of renderables in autosized columns to the console.  
    Columns can contain renderable items, see https://spectreconsole.net/widgets/columns for more information.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the columns.
    #>
    [Reflection.AssemblyMetadata("title", "New-SpectreColumn")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [int] $Padding = 1,
        [switch] $Expand
    )
    begin {
        $columnItems = @()
    }
    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                if ($dataItem -is [Rendering.Renderable]) {
                    $columnItems += $dataItem
                } elseif ($dataItem -is [string]) {
                    $columnItems += [Text]::new($dataItem)
                } else {
                    throw "Data item must be a spectre renderable object or string"
                }
            }
        } else {
            if ($Data -is [Rendering.Renderable]) {
                $columnItems += $Data
            } elseif ($Data -is [string]) {
                $columnItems += [Text]::new($Data)
            } else {
                throw "Data item must be a spectre renderable object or string"
            }
        }
    }
    end {
        $columns = [Columns]::new($columnItems)
        $columns.Expand = $Expand
        $columns.Padding = [Padding]::new($Padding, $Padding, $Padding, $Padding)

        return $columns
    }
}
