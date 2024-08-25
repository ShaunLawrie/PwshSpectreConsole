using module "..\..\private\completions\Transformers.psm1"

function Format-SpectrePadded {
    <#
    .SYNOPSIS
    Wraps a Spectre Console renderable item in padding.

    .DESCRIPTION
    This function that wraps a spectre renderable item in padding.  
    See https://spectreconsole.net/widgets/padder for more information.

    .PARAMETER Data
    A renderable item to wrap in padding.

    .EXAMPLE
    "Item to pad" | Format-SpectrePadded -Padding 1 | Format-SpectrePanel

    .EXAMPLE
    "Item to pad" | Format-SpectrePadded -Padding 4  | Format-SpectrePanel

    .EXAMPLE
    "Item to pad" | Format-SpectrePadded -Top 4 -Left 10 -Right 1 -Bottom 1 | Format-SpectrePanel
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePadded")]
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
