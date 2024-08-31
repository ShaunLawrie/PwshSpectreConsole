using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreBreakdownChart {
    <#
    .SYNOPSIS
    Formats data into a breakdown chart.

    .DESCRIPTION
    This function takes an array of data and formats it into a breakdown chart using BreakdownChart. The chart can be customized with a specified width and color.  
    See https://spectreconsole.net/widgets/breakdownchart for more information.

    .PARAMETER Data
    An array of data to be formatted into a breakdown chart.

    .PARAMETER Width
    The width of the chart. Defaults to the width of the console.

    .PARAMETER HideTags
    Hides the tags on the chart.

    .PARAMETER HideTagValues
    Hides the tag values on the chart.

    .EXAMPLE
    $data = @()

    $data += New-SpectreChartItem -Label "Apples" -Value 10 -Color "Green"
    $data += New-SpectreChartItem -Label "Oranges" -Value 5 -Color "Gold1"
    $data += New-SpectreChartItem -Label "Bananas" -Value 2.2 -Color "#FFFF00"

    Format-SpectreBreakdownChart -Data $data -Width 50
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreBreakdownChart")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ChartItemTransformationAttribute()]
        [object] $Data,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int]$Width = (Get-HostWidth),
        [switch]$HideTags,
        [switch]$HideTagValues,
        [switch]$ShowPercentage
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
        if ($ShowPercentage) {
            $chart = [Spectre.Console.BreakdownChartExtensions]::ShowPercentage($chart)
        }
    }
    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $dataItem.Label, $dataItem.Value, ($dataItem.Color | Convert-ToSpectreColor)) | Out-Null
            }
        } else {
            [Spectre.Console.BreakdownChartExtensions]::AddItem($chart, $Data.Label, $Data.Value, ($Data.Color | Convert-ToSpectreColor)) | Out-Null
        }
    }
    end {
        return $chart
    }
}
