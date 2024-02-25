using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreBarChart {
    <#
    .SYNOPSIS
    Formats and displays a bar chart using the Spectre Console module.
    ![Example bar chart](/barchart.png)

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
    # This example uses the new helper for generating chart items New-SpectreChartItem and shows the various ways of passing color values in
    $data = @()

    $data += New-SpectreChartItem -Label "Apples" -Value 10 -Color "Green"
    $data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "DarkOrange"
    $data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"
    
    Format-SpectreBarChart -Data $data -Title "Fruit Sales" -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBarChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [String] $Title,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int] $Width = (Get-HostWidth),
        [switch] $HideValues
    )
    begin {
        $barChart = [BarChart]::new()
        if ($Title) {
            $barChart.Label = $Title
        }
        if ($HideValues) {
            $barChart.ShowValues = $false
        }
        $barChart.Width = $Width
    }
    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                $barChart = [BarChartExtensions]::AddItem($barChart, $dataItem.Label, $dataItem.Value, ($dataItem.Color | Convert-ToSpectreColor))
            }
        } else {
            $barChart = [BarChartExtensions]::AddItem($barChart, $Data.Label, $Data.Value, ($Data.Color | Convert-ToSpectreColor))
        }
    }
    end {
        Write-AnsiConsole $barChart
    }
}
