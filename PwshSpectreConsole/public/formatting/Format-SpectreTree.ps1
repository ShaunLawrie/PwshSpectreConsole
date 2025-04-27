using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreTree {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectretree/')]
    <#
    .SYNOPSIS
    Formats a hashtable as a tree using Spectre Console.

    .DESCRIPTION
    This function takes a hashtable and formats it as a tree using Spectre Console. The hashtable should have a 'Value' key and a 'Children' key. The 'Value' key should contain the Spectre Console renderable item (text or other objects like calendars etc.) for the node of the tree, and the 'Children' key should contain an array of hashtables representing the child nodes of the node.  
    See https://spectreconsole.net/widgets/tree for more information.

    .PARAMETER Data
    The hashtable to format as a tree.

    .PARAMETER Guide
    The type of line to use for the tree.

    .PARAMETER Color
    The color to use for the tree. This can be a Spectre Console color name or a hex color code. Default is the accent color defined in the script.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to display a tree with multiple children.
    $calendar = Write-SpectreCalendar -Date 2024-07-01 -PassThru
    $data = @{
        Value = "Root"
        Children = @(
            @{
                Value = "Child 1"
                Children = @(
                    @{
                        Value = "Grandchild 1"
                        Children = @()
                    },
                    @{
                        Value = $calendar
                        Children = @()
                    }
                )
            },
            @{
                Value = "Child 2"
                Children = @()
            }
        )
    }

    Format-SpectreTree -Data $data -Guide BoldLine -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTree")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [TreeItemTransformationAttribute()]
        [hashtable] $Data,
        [ValidateSet([SpectreConsoleTreeGuide], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [Alias("Border")]
        [string] $Guide = "Line",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor
    )

    $tree = [Spectre.Console.Tree]::new($Data.Value)
    $tree.Guide = [Spectre.Console.TreeGuide]::$Guide
    $tree.Expanded = $true

    if ($Data.Children) {
        Add-SpectreTreeNode -Node $tree -Children $Data.Children
    }

    $tree.Style = [Spectre.Console.Style]::new($Color)
    
    return $tree
}