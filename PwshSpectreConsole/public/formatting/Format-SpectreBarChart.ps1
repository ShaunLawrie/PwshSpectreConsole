function Format-SpectreBarChart {
    <#
    .SYNOPSIS
    Formats and displays a bar chart using the Spectre Console module.

    .DESCRIPTION
    This function takes an array of data and displays it as a bar chart using the Spectre Console module. The chart can be customized with a title and width.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the chart. Each object should have a Label, Value, and Color property.

    .PARAMETER Title
    The title to be displayed above the chart.

    .PARAMETER Width
    The width of the chart in characters.

    .EXAMPLE
    # This example displays a bar chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = [Spectre.Console.Color]::Green },
        @{ Label = "Oranges"; Value = 5; Color = [Spectre.Console.Color]::Yellow },
        @{ Label = "Bananas"; Value = 3; Color = [Spectre.Console.Color]::Red }
    )
    Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBarChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        $Title,
        $Width = $Host.UI.RawUI.Width
    )
    begin {
        $barChart = [Spectre.Console.BarChart]::new()
        if($Title) {
            $barChart.Label = $Title
        }
        $barChart.Width = $Width
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $dataItem.Label, $dataItem.Value, $dataItem.Color)
            }
        } else {
            $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $Data.Label, $Data.Value, $Data.Color)
        }
    }
    end {
        [Spectre.Console.AnsiConsole]::Write($barChart)
    }
}