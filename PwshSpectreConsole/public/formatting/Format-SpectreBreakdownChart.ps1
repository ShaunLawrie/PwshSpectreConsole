function Format-SpectreBreakdownChart {
    <#
    .SYNOPSIS
    Formats data into a breakdown chart.

    .DESCRIPTION
    This function takes an array of data and formats it into a breakdown chart using Spectre.Console.BreakdownChart. The chart can be customized with a specified width and color.

    .PARAMETER Data
    An array of data to be formatted into a breakdown chart.

    .PARAMETER Width
    The width of the chart. Defaults to the width of the console.

    .EXAMPLE
    # This example displays a breakdown chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = [Spectre.Console.Color]::Red },
        @{ Label = "Oranges"; Value = 20; Color = [Spectre.Console.Color]::Orange1 },
        @{ Label = "Bananas"; Value = 15; Color = [Spectre.Console.Color]::Yellow }
    )
    Format-SpectreBreakdownChart -Data $data -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBreakdownChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        $Width = $Host.UI.RawUI.Width
    )
    begin {
        $chart = [Spectre.Console.BreakdownChart]::new()
        $chart.Width = $Width
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $dataItem.Label, $dataItem.Value, $dataItem.Color) | Out-Null
            }
        } else {
            [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $Data.Label, $Data.Value, $Data.Color) | Out-Null
        }
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($chart)
    }
}