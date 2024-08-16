using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreAligned {
    <#
    .SYNOPSIS
    Wraps a renderable object in a Spectre Console Aligned object.

    .DESCRIPTION
    TODO Description
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