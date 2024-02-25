using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreTree {
    <#
    .SYNOPSIS
    Formats a hashtable as a tree using Spectre Console.

    .DESCRIPTION
    This function takes a hashtable and formats it as a tree using Spectre Console. The hashtable should have a 'Label' key and a 'Children' key. The 'Label' key should contain the label for the root node of the tree, and the 'Children' key should contain an array of hashtables representing the child nodes of the root node. Each child hashtable should have a 'Label' key and a 'Children' key, following the same structure as the root node.

    .PARAMETER Data
    The hashtable to format as a tree.

    .PARAMETER Border
    The type of border to use for the tree.

    .PARAMETER Color
    The color to use for the tree. This can be a Spectre Console color name or a hex color code. Default is the accent color defined in the script.

    .EXAMPLE
    # This example formats a hashtable as a tree with a heavy border and green color.
    $data = @{
        Label = "Root"
        Children = @(
            @{
                Label = "Child 1"
                Children = @(
                    @{
                        Label = "Grandchild 1"
                        Children = @()
                    },
                    @{
                        Label = "Grandchild 2"
                        Children = @()
                    }
                )
            },
            @{
                Label = "Child 2"
                Children = @()
            }
        )
    }

    Format-SpectreTree -Data $data -Guide BoldLine -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTree")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $Data,
        [ValidateSet([SpectreConsoleTreeGuide],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Guide = "Line",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor
    )

    $tree = [Tree]::new($Data.Label)
    $tree.Guide = [TreeGuide]::$Guide

    Add-SpectreTreeNode -Node $tree -Children $Data.Children

    $tree.Style = [Style]::new($Color)
    Write-AnsiConsole $tree
}