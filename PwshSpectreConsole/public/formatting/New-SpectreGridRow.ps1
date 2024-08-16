<#
.SYNOPSIS
TODO - Add synopsis

.DESCRIPTION
TODO - Add description
#>
function New-SpectreGridRow {
    [Reflection.AssemblyMetadata("title", "New-SpectreGridRow")]
    param (
        [Parameter(Mandatory)]
        [array]$Data
    )

    $renderableColumns = @()
    foreach ($column in $Data) {
        $renderableColumns += ConvertTo-Renderable $column
    }

    $gridRow = [SpectreGridRow]::new($renderableColumns)
    
    return $gridRow
}
