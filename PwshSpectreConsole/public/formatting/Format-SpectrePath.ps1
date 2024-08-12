using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectrePath {
    <#
    .SYNOPSIS
    Formats a path into a Spectre Console Path which supports highlighting and truncating.

    .DESCRIPTION
    Formats a path into a Spectre Console Path which supports highlighting and truncating.

    .PARAMETER Path
    The array of objects to be formatted into Json.

    .EXAMPLE
    TODO Example
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectrePath")]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Path,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ValidateSpectreColorTheme()]
        [ColorThemeTransformationAttribute()]
        [hashtable] $PathStyle = @{
            RootColor      = $script:AccentColor
            SeparatorColor = $script:DefaultValueColor
            StemColor      = [Spectre.Console.Color]::Orange1
            LeafColor      = [Spectre.Console.Color]::Red
        }
    )

    $requiredPathKeys = @("RootColor", "SeparatorColor", "StemColor", "LeafColor")
    if (($requiredPathKeys | ForEach-Object { $PathStyle.Keys -contains $_ }) -contains $false) {
        throw "PathStyle must contain the following keys: $($requiredPathKeys -join ', ')"
    }

    $textPath = [Spectre.Console.TextPath]::new($Path)
    $textPath.Justification = [Spectre.Console.Justify]::$Alignment
    $textPath = [Spectre.Console.TextPathExtensions]::RootColor($textPath, $PathStyle.RootColor)
    $textPath = [Spectre.Console.TextPathExtensions]::SeparatorColor($textPath, $PathStyle.SeparatorColor)
    $textPath = [Spectre.Console.TextPathExtensions]::StemColor($textPath, $PathStyle.StemColor)
    $textPath = [Spectre.Console.TextPathExtensions]::LeafColor($textPath, $PathStyle.LeafColor)

    return $textPath
}
