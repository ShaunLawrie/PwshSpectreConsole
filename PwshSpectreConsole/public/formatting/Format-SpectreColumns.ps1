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
    # **Example 1**  
    # This example demonstrates how to display a collection of strings in columns.
    @("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit,", "sed", "do", "eiusmod",
      "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua.", "Ut", "enim", "ad", "minim",
      "veniam,", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea",
      "commodo", "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit",
      "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "excepteur", "sint", "occaecat",
      "cupidatat", "non", "proident", "sunt", "in", "culpa") | Foreach-Object { $_ } | Format-SpectreColumns

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to display a collection of panels that are expanded but with normal sized columns.
    @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel -Expand } | Format-SpectreColumns

    .EXAMPLE
    # **Example 3**  
    # This example demonstrates how to display a collection of panels that are expanded and with expanded columns so it takes up the console width.
    @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel -Expand } | Format-SpectreColumns -Expand
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreColumns")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
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
        if ($Padding -ne 1) {
            $columns.Padding = [Spectre.Console.Padding]::new($Padding, $Padding, $Padding, $Padding)
        }

        return $columns
    }
}
