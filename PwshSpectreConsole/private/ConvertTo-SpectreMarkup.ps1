<#
.SYNOPSIS
    Walks a Markdig inline container and returns a Spectre.Console Markup string.
.DESCRIPTION
    Handles: LiteralInline, EmphasisInline (bold/italic), CodeInline,
    LinkInline, LineBreakInline, HtmlInline (stripped), AutolinkInline.
    Unknown inline types fall back to their literal text content.
#>
function ConvertTo-SpectreMarkup {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [object]$Container   # Markdig.Syntax.Inlines.ContainerInline or LeafInline
    )

    $sb = [System.Text.StringBuilder]::new()

    foreach ($inline in $Container) {
        $typeName = $inline.GetType().Name

        switch ($typeName) {

            'LiteralInline' {
                # Escape Spectre markup special chars: [ and ]
                $text = $inline.ToString()
                $text = $text -replace '\[', '[[' -replace '\]', ']]'
                [void]$sb.Append($text)
            }

            'EmphasisInline' {
                $inner = ConvertTo-SpectreMarkup -Container $inline
                # Markdig uses DelimiterChar and DelimiterCount to distinguish emphasis types:
                # ~ = strikethrough, ~text~
                # * or _ with count >= 2 = bold, **text** or __text__
                # * or _ with count 1 = italic, *text* or _text_
                if ($inline.DelimiterChar -eq '~') {
                    [void]$sb.Append("[strikethrough]$inner[/]")
                } elseif ($inline.DelimiterCount -ge 2) {
                    [void]$sb.Append("[bold]$inner[/]")
                } else {
                    [void]$sb.Append("[italic]$inner[/]")
                }
            }

            'CodeInline' {
                $code = $inline.Content.ToString()
                $code = $code -replace '\[', '[[' -replace '\]', ']]'
                [void]$sb.Append("[cyan on grey11] $code [/]")
            }

            'LinkInline' {
                $linkText = ConvertTo-SpectreMarkup -Container $inline
                $url      = $inline.Url

                if ($inline.IsImage) {
                    # Images can't render — show alt text with a hint
                    [void]$sb.Append("[grey][[image: $linkText]][/]")
                } else {
                    [void]$sb.Append("[link=$url][blue]$linkText[/][/]")
                }
            }

            'AutolinkInline' {
                $url = $inline.Url
                [void]$sb.Append("[link=$url][blue]$url[/][/]")
            }

            'LineBreakInline' {
                if ($inline.IsHard) {
                    [void]$sb.Append("`n")
                } else {
                    [void]$sb.Append(' ')
                }
            }

            'HtmlInline' {
                # Strip HTML tags, keep nothing — avoids leaking raw tags into output
            }

            'HtmlEntityInline' {
                $text = $inline.Transcoded.ToString()
                $text = $text -replace '\[', '[[' -replace '\]', ']]'
                [void]$sb.Append($text)
            }

            'DelimiterInline' {
                # Orphaned delimiter — render as literal
                $text = $inline.ToLiteral()
                $text = $text -replace '\[', '[[' -replace '\]', ']]'
                [void]$sb.Append($text)
            }

            default {
                # Best-effort: try to get string content via ToString()
                try {
                    $text = $inline.ToString()
                    $text = $text -replace '\[', '[[' -replace '\]', ']]'
                    [void]$sb.Append($text)
                } catch {
                    Write-Verbose "ConvertTo-SpectreMarkup: unhandled inline type '$typeName'"
                }
            }
        }
    }

    return $sb.ToString()
}
