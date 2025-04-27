using module "..\..\private\completions\Completers.psm1"

function Format-SpectreRows {
    <#
    .SYNOPSIS
    Renders a collection of renderables in rows to the console.

    .DESCRIPTION
    This function creates a spectre rows widget that renders a collection of renderables in autosized rows to the console.  
    Rows can contain renderable items.  
    See https://spectreconsole.net/widgets/rows for more information.

    .PARAMETER Data
    An array of renderable items containing the data to be displayed in the rows.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to display a collection of strings in rows.
    @("top", "middle", "bottom") | Format-SpectreRows

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to display a collection of renderable items as rows inside a panel, without wrapping the renderables in rows you cannot display them in a panel because a panel only accepts a single item.
    $rows = @()
    $bigText = "lorem ipsum dolor sit amet consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa"
    for ($i = 0; $i -lt 12; $i+= 4) {
        $rows += $bigText | Format-SpectrePadded -Left $i -Top 0 -Bottom 0 -Right 0
    }
    $rows | Format-SpectreRows | Format-SpectrePanel
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectrerows/')]
    [Reflection.AssemblyMetadata("title", "Format-SpectreRows")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
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
                } else {
                    $rowItems += $dataItem | ConvertTo-Renderable
                }
            }
        } else {
            if ($Data -is [Spectre.Console.Rendering.Renderable]) {
                $rowItems += $Data
            } else {
                $rowItems += $Data | ConvertTo-Renderable
            }
        }
    }
    end {
        $rows = [Spectre.Console.Rows]::new($rowItems)
        $rows.Expand = $Expand

        return $rows
    }
}
