using module "..\..\private\completions\Transformers.psm1"

<#
.SYNOPSIS
Adds a row to a Spectre Console table.

.DESCRIPTION
Adds a row to a Spectre Console table. The number of columns in the row must match the number of columns in the table.

.PARAMETER Table
The table to which the row will be added.

.PARAMETER Columns
An array of renderable items containing the data to be displayed in the columns of this row.

.EXAMPLE
# **Example 1**  # This example demonstrates how to add a row to an existing Spectre Console table.
$data = @(
    [pscustomobject]@{Name="John"; Age=25; City="New York"},
    [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
)
$table = Format-SpectreTable -Data $data
$table | Out-SpectreHost

$table = Add-SpectreTableRow -Table $table -Columns "Shaun", 99, "Wellington"
$table | Out-SpectreHost
#>
function Add-SpectreTableRow {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/add-spectretablerow/')]
    [Reflection.AssemblyMetadata("title", "Add-SpectreTableRow")]
    param (
        [Parameter(Mandatory)]
        [Spectre.Console.Table] $Table,
        [Parameter(ValueFromPipeline)]
        [array] $Columns
    )

    if ($table.Columns.Count -ne $Columns.Count) {
        throw "The number of columns $($Columns.Count) in the row must match the number of columns in the table $($table.Columns.Count)"
    }

    $renderableColumns = $Columns | Foreach-Object { $_ | ConvertTo-Renderable }
    $table = [Spectre.Console.TableExtensions]::AddRow($Table, [Spectre.Console.Rendering.Renderable[]]$renderableColumns)

    return $table
}