using module "..\..\private\completions\Completers.psm1"

function Format-SpectreRows {
    <#
    .SYNOPSIS
    Renders a collection of renderables in rows to the console.

    .DESCRIPTION
    This function creates a spectre rows widget that renders a collection of renderables in autosized rows to the console.  
    Rows can contain renderable items, see https://spectreconsole.net/widgets/rows for more information.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the rows.
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreRows")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [switch] $Expand
    )
    begin {
        $rowItems = @()
    }
    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                if ($dataItem -is [Spectre.Console.Rendering.Renderable]) {
                    $rowItems += $dataItem
                } elseif ($dataItem -is [string]) {
                    $rowItems += [Spectre.Console.Text]::new($dataItem)
                } else {
                    throw "Data item must be a spectre renderable object or string"
                }
            }
        } else {
            if ($Data -is [Spectre.Console.Rendering.Renderable]) {
                $rowItems += $Data
            } elseif ($Data -is [string]) {
                $rowItems += [Spectre.Console.Text]::new($Data)
            } else {
                throw "Data item must be a spectre renderable object or string"
            }
        }
    }
    end {
        $rows = [Spectre.Console.Rows]::new($rowItems)
        $rows.Expand = $Expand

        return $rows
    }
}
