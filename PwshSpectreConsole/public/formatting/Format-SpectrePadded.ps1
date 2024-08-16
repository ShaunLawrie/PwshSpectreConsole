using module "..\..\private\completions\Transformers.psm1"

function Format-SpectrePadded {
    <#
    .SYNOPSIS
    Renders a collection of renderables in rows to the console.

    .DESCRIPTION
    This function creates a spectre rows widget that renders a collection of renderables in autosized rows to the console.  
    Rows can contain renderable items, see https://spectreconsole.net/widgets/rows for more information.

    .PARAMETER Data
    An array of objects containing the data to be displayed in the rows.
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePadded")]
    # two parameter sets, one for padding evenly and one for specifing tlbr separately
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [Parameter(ParameterSetName = 'Global', Mandatory)]
        [int] $Padding,
        [Parameter(ParameterSetName = 'Specific', Mandatory)]
        [int] $Top,
        [Parameter(ParameterSetName = 'Specific', Mandatory)]
        [int] $Left,
        [Parameter(ParameterSetName = 'Specific', Mandatory)]
        [int] $Bottom,
        [Parameter(ParameterSetName = 'Specific', Mandatory)]
        [int] $Right,
        [Parameter(ParameterSetName = 'Expand', Mandatory)]
        [switch] $Expand
    )
    
    $paddedRenderable = [Spectre.Console.Padder]::new($Data)

    if ($PSCmdlet.ParameterSetName -eq 'Expand') {
        $paddedRenderable.Expand = $true
    } elseif ($PSCmdlet.ParameterSetName -eq 'Global') {
        $paddedRenderable.Padding = [Spectre.Console.Padding]::new($Padding)
    } elseif ($PSCmdlet.ParameterSetName -eq 'Specific') {
        $paddedRenderable.Padding = [Spectre.Console.Padding]::new($Left, $Top, $Right, $Bottom)
    }

    return $paddedRenderable
}
