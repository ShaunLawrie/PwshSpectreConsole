using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreTextPath {
    <#
    .SYNOPSIS
    Formats a path into a Spectre Console Path which supports highlighting and truncating.

    .DESCRIPTION
    Formats a path into a Spectre Console Path which supports highlighting and truncating.  
    See https://spectreconsole.net/widgets/text-path for more information.

    .PARAMETER Path
    The directory/file path to format

    .PARAMETER Alignment
    The alignment of the path. Defaults to "Left".

    .PARAMETER PathStyle
    A hashtable of Spectre Console colors or color names to style the path output.
    e.g.
    ```
    @{
        RootColor      = [Spectre.Console.Color]::Cyan2
        SeparatorColor = [Spectre.Console.Color]::Aqua
        StemColor      = [Spectre.Console.Color]::Orange1
        LeafColor      = "HotPink"
    }
    ```

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to format a PowerShell path as a Spectre Console Path with syntax highlighting.
    Get-Location | Format-SpectreTextPath | Out-SpectreHost
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectretextpath/')]
    [Reflection.AssemblyMetadata("title", "Format-SpectreTextPath")]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [string] $Path,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
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
    $textPath.RootStyle = $PathStyle.RootColor
    $textPath.SeparatorStyle = $PathStyle.SeparatorColor
    $textPath.StemStyle = $PathStyle.StemColor
    $textPath.LeafStyle = $PathStyle.LeafColor

    return $textPath
}
