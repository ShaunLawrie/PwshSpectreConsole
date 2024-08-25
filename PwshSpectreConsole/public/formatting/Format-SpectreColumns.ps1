using module "..\..\private\completions\Completers.psm1"

function Format-SpectreColumns {
    <#
    .SYNOPSIS
    Renders a collection of renderables in columns to the console.

    .DESCRIPTION
    This function creates a spectre columns widget that renders a collection of renderables in autosized columns to the console.  
    Columns can contain renderable items.  
    See https://spectreconsole.net/widgets/columns for more information.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the columns.

    .PARAMETER Padding
    The padding to apply to the columns.

    .PARAMETER Expand
    A switch to expand the columns to fill the available space.

    .EXAMPLE
    @("left", "middle", "right") | Format-SpectreColumns

    .EXAMPLE
    @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel -Expand } | Format-SpectreColumns

    .EXAMPLE
    @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel -Expand } | Format-SpectreColumns -Expand
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreColumns")]
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
                if ($dataItem -is [Spectre.Console.Rendering.Renderable]) {
                    $columnItems += $dataItem
                } elseif ($dataItem -is [string]) {
                    $columnItems += [Spectre.Console.Text]::new($dataItem)
                } else {
                    throw "Data item must be a spectre renderable object or string"
                }
            }
        } else {
            if ($Data -is [Spectre.Console.Rendering.Renderable]) {
                $columnItems += $Data
            } elseif ($Data -is [string]) {
                $columnItems += [Spectre.Console.Text]::new($Data)
            } else {
                throw "Data item must be a spectre renderable object or string"
            }
        }
    }
    end {
        $columns = [Spectre.Console.Columns]::new($columnItems)
        $columns.Expand = $Expand
        $columns.Padding = [Spectre.Console.Padding]::new($Padding, $Padding, $Padding, $Padding)

        return $columns
    }
}
