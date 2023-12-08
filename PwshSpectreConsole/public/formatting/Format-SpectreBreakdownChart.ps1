using module "..\..\private\completions\Completers.psm1"

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

    .PARAMETER HideTags
    Hides the tags on the chart.

    .PARAMETER HideTagValues
    Hides the tag values on the chart.

    .EXAMPLE
    # This example displays a breakdown chart with the title "Fruit Sales" and a width of 50 characters.
    $data = @(
        @{ Label = "Apples"; Value = 10; Color = "Red" },
        @{ Label = "Oranges"; Value = 20; Color = "Orange1" },
        @{ Label = "Bananas"; Value = 15; Color = "Yellow" }
    )
    Format-SpectreBreakdownChart -Data $data -Width 50

    .EXAMPLE
    # This example uses the new helper for generating chart items New-SpectreChartItem and the various ways of passing color values in.
    $data = @()

    $data += New-SpectreChartItem -Label "Apples" -Value 10 -Color [Spectre.Console.Color]::Green
    $data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "Orange"
    $data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"

    Format-SpectreBreakdownChart -Data $data -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBreakdownChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [ValidateSet([SpectreConsoleWidth],ErrorMessage = "Value '{0}' is invalid. Cannot exceed console width.")]
        [int]$Width = [console]::BufferWidth,
        [switch]$HideTags,
        [Switch]$HideTagValues
    )
    begin {
        $chart = [Spectre.Console.BreakdownChart]::new()
        $chart.Width = $Width
        if ($HideTags) {
            $chart.ShowTags = $false
        }
        if ($HideTagValues) {
            $chart.ShowTagValues = $false
        }
    }
    process {
        if($Data -is [array]) {
            foreach($dataItem in $Data) {
                [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $dataItem.Label, $dataItem.Value, ($dataItem.Color | Convert-ToSpectreColor)) | Out-Null
            }
        } else {
            [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $Data.Label, $Data.Value, ($Data.Color | Convert-ToSpectreColor)) | Out-Null
        }
    }
    end {
        Write-AnsiConsole $chart
    }
}
