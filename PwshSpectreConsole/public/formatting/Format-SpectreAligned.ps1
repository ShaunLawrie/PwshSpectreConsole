using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreAligned {
    <#
    .SYNOPSIS
    Wraps a renderable object in a Spectre Console Aligned object.

    .DESCRIPTION
    This wraps a renderable object in a Spectre Console Aligned object. This allows you to align the object horizontally and vertically within a space. Aligned objects are always expanded so they take up all available horizontal space.  

    .PARAMETER Data
    The renderable object to align.

    .PARAMETER HorizontalAlignment
    The horizontal alignment of the object.

    .PARAMETER VerticalAlignment
    The vertical alignment of the object.

    .EXAMPLE
    "hello right hand side" | Format-SpectreAligned -HorizontalAlignment Right -VerticalAlignment Middle | Format-SpectrePanel -Expand -Height 9
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreAligned")]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [ValidateSet([SpectreConsoleHorizontalAlignment], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $HorizontalAlignment = "Center",
        [ValidateSet([SpectreConsoleVerticalAlignment], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $VerticalAlignment = "Middle"
    )

    $aligned = [Spectre.Console.Align]::new(
        $Data,
        [Spectre.Console.HorizontalAlignment]::$HorizontalAlignment,
        [Spectre.Console.VerticalAlignment]::$VerticalAlignment
    )
    
    return $aligned
}