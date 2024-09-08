<#
.SYNOPSIS
Creates a new SpectreGridRow object.

.DESCRIPTION
Creates a new SpectreGridRow object with the specified columns for use in Format-SpectreGrid. PowerShell collapses nested arrays, so you must use this function to create an array of SpectreGridRow objects to provide to Format-SpectreGrid.

.PARAMETER Data
An array of renderable items containing the data to be displayed in the columns of this row.

.PARAMETER Justify
The justification to apply to each data item in this row. The default is Left.

.EXAMPLE
# **Example 1**  # This example demonstrates how to create a grid with two rows and three columns.
$columns = @()
$columns += "Column 1" | Format-SpectrePanel
$columns += "Column 2" | Format-SpectrePanel
$columns += "Column 3" | Format-SpectrePanel

$rows = @(
  (New-SpectreGridRow -Data $columns),
  (New-SpectreGridRow -Data $columns)
)

$rows | Format-SpectreGrid
#>
function New-SpectreGridRow {
    [Reflection.AssemblyMetadata("title", "New-SpectreGridRow")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array]$Data
    )

    $renderableColumns = @()
    foreach ($column in $Data) {
        $renderableColumns += ConvertTo-Renderable $column
    }

    $gridRow = [SpectreGridRow]::new($renderableColumns)
    
    return $gridRow
}
