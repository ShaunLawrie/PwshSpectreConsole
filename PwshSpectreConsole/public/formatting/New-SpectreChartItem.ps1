using module "..\..\private\models\SpectreChartItem.psm1"
using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

<#
.SYNOPSIS
Creates a new SpectreChartItem object.

.DESCRIPTION
The New-SpectreChartItem function creates a new SpectreChartItem object with the specified label, value, and color for use in Format-SpectreBarChart and Format-SpectreBreakdownChart.

.PARAMETER Label
The label for the chart item.

.PARAMETER Value
The value for the chart item.

.PARAMETER Color
The color for the chart item. Must be a valid Spectre color as name, hex or a Spectre.Console.Color object.

.EXAMPLE
# This example creates an array of new SpectreChartItem objects you can pass into the chart functions.
$data = @()
$data += New-SpectreChartItem -Label "Sales" -Value 1000 -Color "green"
$data += New-SpectreChartItem -Label "Expenses" -Value 500 -Color "#ff0000"
$data += New-SpectreChartItem -Label "Profit" -Value 500 -Color ([Spectre.Console.Color]::Blue)

#>
function New-SpectreChartItem {
    [Reflection.AssemblyMetadata("title", "New-SpectreChartItem")]
    param (
        [Parameter(Mandatory)]
        [string]$Label,
        [Parameter(Mandatory)]
        [double]$Value,
        [Parameter(Mandatory)]
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color]$Color
    )

    return [SpectreChartItem]::new($Label, $Value, $Color)
}
