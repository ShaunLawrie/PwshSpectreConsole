using namespace Spectre.Console

<#
.SYNOPSIS
Recursively adds child nodes to a parent node in a Spectre.Console tree.

.DESCRIPTION
The Add-SpectreTreeNode function adds child nodes to a parent node in a Spectre.Console tree. It does this recursively, so it can handle nested child nodes.

.PARAMETER Node
The parent node to which the child nodes will be added.

.PARAMETER Children
An array of child nodes to be added to the parent node. Each child node should be an object with a 'Label' property and a 'Children' property (which can be an empty array if the child has no children of its own).

.NOTES
See Format-SpectreTree for usage.
#>
function Add-SpectreTreeNode {
    param (
        [Parameter(Mandatory)]
        [IHasTreeNodes] $Node,
        [Parameter(Mandatory)]
        [array] $Children
    )

    foreach($child in $Children) {
        $newNode = [HasTreeNodeExtensions]::AddNode($Node, $child.Label)
        if($child.Children.Count -gt 0) {
            Add-SpectreTreeNode -Node $newNode -Children $child.Children
        }
    }
}