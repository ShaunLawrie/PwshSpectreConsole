using module "..\..\private\completions\Completers.psm1"

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

    .PARAMETER HideValues
    Hides the values from being displayed on the chart.

    .EXAMPLE
    # This example displays a bar chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = "Green" },
        @{ Label = "Oranges"; Value = 5; Color = "Yellow" },
        @{ Label = "Bananas"; Value = 3; Color = "Red" }
    )
    Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50

    .EXAMPLE
    # This example uses the new helper for generating chart items New-SpectreChartItem and the various ways of passing color values in
    $data = @()

    $data += New-SpectreChartItem -Label "Apples" -Value 10 -Color [Spectre.Console.Color]::Green
    $data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "Orange"
    $data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"

    Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBarChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [String]$Title,
        [ValidateSet([SpectreConsoleWidth],ErrorMessage = "Value '{0}' is invalid. Cannot exceed console width.")]
        [int]$Width = [console]::BufferWidth,
        [switch]$HideValues
    )
    begin {
        $barChart = [Spectre.Console.BarChart]::new()
        if($Title) {
            $barChart.Label = $Title
        }
        if ($HideValues) {
            $barChart.ShowValues = $false
        }
        $barChart.Width = $Width
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $dataItem.Label, $dataItem.Value, ($dataItem.Color | Convert-ToSpectreColor))
            }
        } else {
            $barChart = [Spectre.Console.BarChartExtensions]::AddItem($barChart, $Data.Label, $Data.Value, ($Data.Color | Convert-ToSpectreColor))
        }
    }
    end {
        Write-AnsiConsole $barChart
    }
}
