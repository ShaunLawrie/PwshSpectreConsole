using module "..\..\private\models\SpectreChartItem.psm1"
using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

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
# **Example 1**  # This example demonstrates how to use SpectreChartItems to create a breakdown chart.
$data = @()
$data += New-SpectreChartItem -Label "Sales" -Value 1000 -Color "green"
$data += New-SpectreChartItem -Label "Expenses" -Value 500 -Color "#ff0000"
$data += New-SpectreChartItem -Label "Profit" -Value 420 -Color ([Spectre.Console.Color]::Blue)
Write-SpectreHost "`nGenerate a bar chart`n"
$data | Format-SpectreBarChart
Write-SpectreHost "`nGenerate a breakdown chart`n"
$data | Format-SpectreBreakdownChart
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
        [Spectre.Console.Color]$Color
    )

    return [SpectreChartItem]::new($Label, $Value, $Color)
}
