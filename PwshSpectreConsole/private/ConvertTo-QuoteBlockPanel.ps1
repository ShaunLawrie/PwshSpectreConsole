<#
.SYNOPSIS
    Converts a Markdig QuoteBlock to a bordered Spectre.Console Panel, recursing for nested quotes.
.DESCRIPTION
    Collects ParagraphBlock children as italic grey Markup. When a nested QuoteBlock is
    encountered, pending text is flushed and the inner block is converted by a recursive
    call, producing a nested Panel. All collected renderables are wrapped in a single
    Heavy-bordered Panel matching the project's blockquote visual style.
.NOTES
    See Convert-MarkdigBlockToRenderable for usage.
#>
function ConvertTo-QuoteBlockPanel {
    param(
        [Parameter(Mandatory)]
        [object]$QuoteBlock
    )

    $collected = [System.Collections.Generic.List[object]]::new()
    $sb        = [System.Text.StringBuilder]::new()

    foreach ($childBlock in $QuoteBlock) {
        $cn = $childBlock.GetType().Name

        if ($cn -eq 'ParagraphBlock') {
            $text = ConvertTo-SpectreMarkup -Container $childBlock.Inline
            [void]$sb.AppendLine($text)
        } elseif ($cn -eq 'QuoteBlock') {
            # Flush accumulated paragraph text before nesting
            if ($sb.Length -gt 0) {
                $flushed = $sb.ToString().TrimEnd()
                $collected.Add([Spectre.Console.Markup]::new("[italic grey]$flushed[/]"))
                [void]$sb.Clear()
            }
            $collected.Add((ConvertTo-QuoteBlockPanel $childBlock))
        }
    }

    if ($sb.Length -gt 0) {
        $flushed = $sb.ToString().TrimEnd()
        $collected.Add([Spectre.Console.Markup]::new("[italic grey]$flushed[/]"))
    }

    $content = if ($collected.Count -eq 1) {
        $collected[0]
    } elseif ($collected.Count -gt 1) {
        [Spectre.Console.Rows]::new($collected.ToArray())
    } else {
        [Spectre.Console.Markup]::new('')
    }

    $panel             = [Spectre.Console.Panel]::new($content)
    $panel.Border      = [Spectre.Console.BoxBorder]::Heavy
    $panel.BorderStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Grey46)
    $panel.Padding     = [Spectre.Console.Padding]::new(1, 0)
    return $panel
}
