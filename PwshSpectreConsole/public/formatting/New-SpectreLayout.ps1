using module "..\..\private\completions\Transformers.psm1"

function New-SpectreLayout {
    <#
    .SYNOPSIS
    Creates a new Spectre Layout object.

    .DESCRIPTION
    The New-SpectreLayout function creates a new Spectre Layout object with the specified data, columns, or rows. This function is used to create a layout object that can be used to split the console into multiple sections.  
    You can only have either rows OR columns in a layout and can compose layouts of layouts to create complex layouts.

    .PARAMETER Data
    The data to be displayed in the layout.

    .PARAMETER Columns
    The columns to be displayed in the layout.

    .PARAMETER Rows
    The rows to be displayed in the layout.

    .PARAMETER Ratio
    The ratio of the layout, when composing layouts of layouts you can use a higher ratio in one layout to make it larger than the other layouts.

    .PARAMETER Name
    The name of the layout, this is used when you want to access one of the layouts in a nested layout to update the contents.  
    e.g. in the example below to update the contents of row1 you would use `$root = $root["row1"].Update(("hello row 1 again" | Format-SpectrePanel))`

    .PARAMETER MinimumSize
    The minimum size of the layout, this can be used to ensure a layout is at least the minimum width.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to create a layout with a calendar, a list of files, and a panel with a calendar aligned to the middle and center.
    $calendar = Write-SpectreCalendar -Date (Get-Date) -PassThru
    $files = Get-ChildItem | Select-Object Name, LastWriteTime -First 3 | Format-SpectreTable | Format-SpectreAligned -HorizontalAlignment Right -VerticalAlignment Bottom

    $panel1 = $files | Format-SpectrePanel -Header "panel 1 (align bottom right)" -Expand -Color Green
    $panel2 = "hello row 2" | Format-SpectrePanel -Header "panel 2" -Expand -Color Blue
    $panel3 = $calendar | Format-SpectreAligned | Format-SpectrePanel -Header "panel 3 (align middle center)" -Expand -Color Yellow

    $row1 = New-SpectreLayout -Name "row1" -Data $panel1 -Ratio 1
    $row2 = New-SpectreLayout -Name "row2" -Columns @($panel2, $panel3) -Ratio 2
    $root = New-SpectreLayout -Name "root" -Rows @($row1, $row2)

    $root | Out-SpectreHost
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/new-spectrelayout/')]
    [Reflection.AssemblyMetadata("title", "New-SpectreLayout")]
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
