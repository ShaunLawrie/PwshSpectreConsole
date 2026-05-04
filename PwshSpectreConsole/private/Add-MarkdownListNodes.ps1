<#
.SYNOPSIS
    Recursively populates a Spectre.Console Tree with nodes from a Markdig ListBlock.
.DESCRIPTION
    Walks a Markdig ListBlock and adds each item as a TreeNode on the supplied parent
    (which is either a Tree root or a parent TreeNode). Nested ListBlocks found inside
    a ListItemBlock are processed recursively, producing child nodes. Bullet style
    changes per depth level (• → ◦ → ▸) to visually distinguish nesting.
.NOTES
    See Convert-MarkdigBlockToRenderable for usage.
#>
function Add-MarkdownListNodes {
    param(
        [Parameter(Mandatory)]
        [Spectre.Console.IHasTreeNodes]$Parent,
        [Parameter(Mandatory)]
        [object]$ListBlock,
        [int]$Depth = 0
    )

    $ordered = $ListBlock.IsOrdered
    $index   = if ($ordered -and $ListBlock.OrderedStart) { [int]$ListBlock.OrderedStart } else { 1 }
    $bullet  = switch ($Depth) {
        0       { '•' }
        1       { '◦' }
        default { '▸' }
    }

    foreach ($item in $ListBlock) {
        $itemText    = ''
        $nestedLists = [System.Collections.Generic.List[object]]::new()

        foreach ($childBlock in $item) {
            $cn = $childBlock.GetType().Name
            if ($cn -eq 'ParagraphBlock') {
                $itemText += ConvertTo-SpectreMarkup -Container $childBlock.Inline
            } elseif ($cn -eq 'ListBlock') {
                [void]$nestedLists.Add($childBlock)
            }
        }

        $label = if ($ordered) {
            "[bold cyan]$index.[/] $itemText"
        } else {
            "[bold cyan]$bullet[/] $itemText"
        }

        $node = [Spectre.Console.HasTreeNodeExtensions]::AddNode(
            $Parent, [Spectre.Console.Markup]::new($label)
        )

        foreach ($nested in $nestedLists) {
            Add-MarkdownListNodes -Parent $node -ListBlock $nested -Depth ($Depth + 1)
        }

        $index++
    }
}
