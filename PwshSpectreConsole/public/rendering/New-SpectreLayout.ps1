using module "..\..\private\completions\Transformers.psm1"

function New-SpectreLayout {
    param (
        [Parameter(ParameterSetName = 'Data')]
        [RenderableTransformationAttribute()]
        [object] $Data,
        # Create a layout with the children layouts as columns
        [Parameter(ParameterSetName = 'Columns', Mandatory)]
        [array] $Columns,
        # Create a layout with the children layouts as rows
        [Parameter(ParameterSetName = 'Rows', Mandatory)]
        [array] $Rows,
        # global params
        [int] $Ratio = 1,
        [string] $Name,
        [int] $MinimumSize = 1
    )

    $layout = [Spectre.Console.Layout]::new($Name)
    $layout.Ratio = $Ratio
    $layout.MinimumSize = $MinimumSize

    if ($PSCmdlet.ParameterSetName -eq 'Columns') {
        $layoutColumns = $Columns | ForEach-Object {
            if ($_ -is [Spectre.Console.Layout]) {
                $_
            } else {
                New-SpectreLayout -Data $_
            }
        }
        $layout = $layout.SplitColumns($layoutColumns)
    } elseif ($PSCmdlet.ParameterSetName -eq 'Rows') {
        $layoutRows = $Rows | ForEach-Object {
            if ($_ -is [Spectre.Console.Layout]) {
                $_
            } else {
                New-SpectreLayout -Data $_
            }
        }
        $layout = $layout.SplitRows($layoutRows)
    } elseif ($PSCmdlet.ParameterSetName -eq 'Data') {
        $layout = $layout.Update($Data)
    }

    return $layout
}
