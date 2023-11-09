using module "..\..\private\attributes\ColorAttributes.psm1"
using module "..\..\private\attributes\BorderAttributes.psm1"

function Format-SpectreTree {
    <#
    .SYNOPSIS
    Formats a hashtable as a tree using Spectre Console.

    .DESCRIPTION
    This function takes a hashtable and formats it as a tree using Spectre Console. The hashtable should have a 'Label' key and a 'Children' key. The 'Label' key should contain the label for the root node of the tree, and the 'Children' key should contain an array of hashtables representing the child nodes of the root node. Each child hashtable should have a 'Label' key and a 'Children' key, following the same structure as the root node.

    .PARAMETER Data
    The hashtable to format as a tree.

    .PARAMETER Border
    The type of border to use for the tree. Valid values are 'Rounded', 'Heavy', 'Light', 'Double', 'Solid', 'Ascii', and 'None'. Default is 'Rounded'.

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

    Format-SpectreTree -Data $data -Border "Heavy" -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTree")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $Data,
        [ValidateSpectreBorder()]
        [ArgumentCompletionsSpectreBorders()]
        [string] $Border = "Rounded",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup()
    )

    function Add-SpectreTreeNode {
        param (
            $Node,
            $Children
        )
    
        foreach($child in $Children) {
            $newNode = [Spectre.Console.HasTreeNodeExtensions]::AddNode($Node, $child.Label)
            if($child.Children.Count -gt 0) {
                Add-SpectreTreeNode -Node $newNode -Children $child.Children
            }
        }
    }

    $tree = [Spectre.Console.Tree]::new($Data.Label)

    Add-SpectreTreeNode -Node $tree -Children $Data.Children

    $tree.Style = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
    [Spectre.Console.AnsiConsole]::Write($tree)
}