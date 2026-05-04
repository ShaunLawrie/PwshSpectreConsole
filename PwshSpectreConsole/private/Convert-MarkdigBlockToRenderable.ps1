<#
.SYNOPSIS
    Walks a Markdig block container and returns an array of Spectre.Console
    IRenderable objects, one per block-level element.
.DESCRIPTION
    Handles: HeadingBlock, ParagraphBlock, FencedCodeBlock, CodeBlock,
    QuoteBlock, ListBlock/ListItemBlock, ThematicBreakBlock, HtmlBlock,
    Tables (via Markdig.Extensions.Tables).
    Unknown block types are rendered as plain Markup text.
#>
function Convert-MarkdigBlockToRenderable {
    [CmdletBinding()]
    [OutputType('Spectre.Console.IRenderable[]')]
    param(
        [Parameter(Mandatory)]
        [object]$Container,   # Markdig.Syntax.ContainerBlock or MarkdownDocument
        [switch]$IncludeImages,
        [int]$ImageMaxWidth = 0,
        [string]$ImageBasePath,
        [string]$Justify = 'Left'
    )


    $renderables = [System.Collections.Generic.List[object]]::new()
    $script:RecursionDepth = if ($script:RecursionDepth) { $script:RecursionDepth + 1 } else { 1 }

    if ($script:RecursionDepth -gt 20) {
        Write-Verbose "Convert-MarkdigBlockToRenderable: max recursion depth (20) exceeded"
        $script:RecursionDepth--
        return $renderables.ToArray()
    }

    try {
    foreach ($block in $Container) {
        $typeName = $block.GetType().Name

        switch ($typeName) {

            # ------------------------------------------------------------------
            # Headings  →  Rule with styled title
            # ------------------------------------------------------------------
            'HeadingBlock' {
                $text  = ConvertTo-SpectreMarkup -Container $block.Inline
                $level = $block.Level

                $style = switch ($level) {
                    1 { '[bold yellow]' }
                    2 { '[bold cyan]'   }
                    3 { '[bold green]'  }
                    4 { '[bold blue]'   }
                    5 { '[bold grey]'   }
                    6 { '[grey]'        }
                    default { '[bold]'  }
                }

                if ($level -le 3) {
                    $rule = [Spectre.Console.Rule]::new("$style$text[/]")
                    $rule.Justification = [Spectre.Console.Justify]::Left
                    $renderables.Add($rule)
                } else {
                    $prefix = '#' * $level
                    $renderables.Add(
                        [Spectre.Console.Markup]::new("$style$prefix $text[/]`n")
                    )
                }
            }

            # ------------------------------------------------------------------
            # Paragraphs  →  Markup (images rendered inline when -IncludeImages)
            # ------------------------------------------------------------------
            'ParagraphBlock' {
                if ($IncludeImages) {
                    $textBuf = [System.Text.StringBuilder]::new()
                    foreach ($inline in $block.Inline) {
                        $isImage   = $false
                        $imgUrl    = $null
                        $linkUrl   = $null
                        $imageNode = $null
                        $typeName  = $inline.GetType().Name

                        if ($typeName -eq 'LinkInline') {
                            if ($inline.IsImage) {
                                $isImage   = $true
                                $imgUrl    = $inline.Url
                                $imageNode = $inline
                            } else {
                                foreach ($child in $inline) {
                                    if ($child.GetType().Name -eq 'LinkInline' -and $child.IsImage) {
                                        $isImage   = $true
                                        $imgUrl    = $child.Url
                                        $linkUrl   = $inline.Url
                                        $imageNode = $child
                                        break
                                    }
                                }
                            }
                        }

                        if ($isImage) {
                            $buffered = $textBuf.ToString()
                            if ($buffered) {
                                $renderables.Add([Spectre.Console.Markup]::new("$buffered`n"))
                                [void]$textBuf.Clear()
                            }

                            $url = $imgUrl
                            if (-not ($url.StartsWith('http://') -or $url.StartsWith('https://'))) {
                                $base = if ($ImageBasePath) { $ImageBasePath } else { $PWD.Path }
                                $url  = Join-Path $base $url
                            }

                            try {
                                $imgParams = @{ ImagePath = $url; ErrorAction = 'Stop' }
                                if ($ImageMaxWidth -gt 0) { $imgParams.MaxWidth = $ImageMaxWidth }
                                $image = Get-SpectreImage @imgParams
                                $renderables.Add($image)

                                if ($linkUrl) {
                                    $renderables.Add([Spectre.Console.Markup]::new("[dim]Link: [link=$linkUrl]$linkUrl[/][/]`n"))
                                }
                            } catch {
                                $altText = ConvertTo-SpectreMarkup -Container $imageNode
                                Write-Verbose "Convert-MarkdigBlockToRenderable: image '$url' failed — $_"
                                $renderables.Add([Spectre.Console.Markup]::new("[grey][[image: $altText]][/]`n"))

                                if ($linkUrl) {
                                    $renderables.Add([Spectre.Console.Markup]::new("[dim]Link: [link=$linkUrl]$linkUrl[/][/]`n"))
                                }
                            }
                        } else {
                            [void]$textBuf.Append((ConvertTo-SpectreMarkup -Container @($inline)))
                        }
                    }
                    $remaining = $textBuf.ToString()
                    if ($remaining) {
                        $renderables.Add([Spectre.Console.Markup]::new("$remaining`n"))
                    }
                } else {
                    $text = ConvertTo-SpectreMarkup -Container $block.Inline
                    $renderables.Add([Spectre.Console.Markup]::new("$text`n"))
                }
            }

            # ------------------------------------------------------------------
            # Fenced code blocks  →  Panel with language label + syntax colour
            # ------------------------------------------------------------------
            { $_ -in 'FencedCodeBlock', 'CodeBlock' } {
                $lang = if ($typeName -eq 'FencedCodeBlock' -and $block.Info) {
                    $block.Info.Trim()
                } else {
                    ''
                }

                $header      = if ($lang) { $lang } else { 'code' }
                $highlighted = ConvertTo-SpectreCodeMarkup -Code $block.Lines.ToString().TrimEnd() -Language $lang

                $panel             = [Spectre.Console.Panel]::new([Spectre.Console.Markup]::new($highlighted))
                $panel.Header      = [Spectre.Console.PanelHeader]::new("[dim]$header[/]")
                $panel.Border      = [Spectre.Console.BoxBorder]::Rounded
                $panel.BorderStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Grey)
                $panel.Padding     = [Spectre.Console.Padding]::new(1, 0)
                $renderables.Add($panel)
            }

            # ------------------------------------------------------------------
            # Blockquotes  →  bordered Panel (nested blockquotes recurse)
            # ------------------------------------------------------------------
            'QuoteBlock' {
                $renderables.Add((ConvertTo-QuoteBlockPanel $block))
            }

            # ------------------------------------------------------------------
            # Lists  →  Spectre.Console.Tree (supports nested sub-lists)
            # ------------------------------------------------------------------
            'ListBlock' {
                $tree = [Spectre.Console.Tree]::new([Spectre.Console.Markup]::new(""))
                Add-MarkdownListNodes -Parent $tree -ListBlock $block -Depth 0

                $listPanel         = [Spectre.Console.Panel]::new($tree)
                $listPanel.Border  = [Spectre.Console.BoxBorder]::None
                $listPanel.Padding = [Spectre.Console.Padding]::new(0, 0)
                $listPanel.Expand  = $false
                $renderables.Add($listPanel)
            }

            # ------------------------------------------------------------------
            # Thematic break  →  Rule
            # ------------------------------------------------------------------
            'ThematicBreakBlock' {
                $rule = [Spectre.Console.Rule]::new()
                $rule.Style = [Spectre.Console.Style]::new([Spectre.Console.Color]::Grey)
                $renderables.Add($rule)
            }

            # ------------------------------------------------------------------
            # Tables (Markdig extension) — cells support inline Markdown
            # ------------------------------------------------------------------
            'Table' {
                $spectreTable             = [Spectre.Console.Table]::new()
                $spectreTable.Border      = [Spectre.Console.TableBorder]::Rounded
                $spectreTable.BorderStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Grey)
                $spectreTable.Expand      = $false

                $headerProcessed = $false

                foreach ($row in $block) {
                    $rowTypeName = $row.GetType().Name

                    if ($rowTypeName -eq 'TableRow') {
                        $cells = @($row | ForEach-Object {
                            ConvertTo-SpectreMarkup -Container $_.Inline
                        })

                        if (-not $headerProcessed -and $row.IsHeader) {
                            foreach ($cell in $cells) {
                                [void]$spectreTable.AddColumn(
                                    [Spectre.Console.TableColumn]::new(
                                        [Spectre.Console.Markup]::new("[bold]$cell[/]")
                                    )
                                )
                            }
                            $headerProcessed = $true
                        } elseif (-not $row.IsHeader) {
                            if (-not $headerProcessed) {
                                for ($i = 0; $i -lt $cells.Count; $i++) {
                                    [void]$spectreTable.AddColumn([Spectre.Console.TableColumn]::new(''))
                                }
                                $headerProcessed = $true
                            }
                            $renderableCells = [Spectre.Console.Markup[]]@(
                                $cells | ForEach-Object { [Spectre.Console.Markup]::new($_) }
                            )
                            [void][Spectre.Console.TableExtensions]::AddRow($spectreTable, $renderableCells)
                        }
                    }
                }

                $renderables.Add($spectreTable)
            }

            # ------------------------------------------------------------------
            # Raw HTML blocks  →  strip and skip
            # ------------------------------------------------------------------
            'HtmlBlock' {
                Write-Verbose "Convert-MarkdigBlockToRenderable: skipping HtmlBlock"
            }

            # ------------------------------------------------------------------
            # Catch-all for container blocks (e.g. custom extensions)
            # ------------------------------------------------------------------
            default {
                if ($block -is [Markdig.Syntax.ContainerBlock]) {
                    $nestedParams = @{
                        Container     = $block
                        IncludeImages = $IncludeImages
                        ImageMaxWidth = $ImageMaxWidth
                        ImageBasePath = $ImageBasePath
                        Justify       = $Justify
                    }
                    $nested = Convert-MarkdigBlockToRenderable @nestedParams
                    foreach ($r in $nested) { $renderables.Add($r) }
                } else {
                    Write-Verbose "Convert-MarkdigBlockToRenderable: unhandled block type '$typeName'"
                }
            }
        }
    }

    # Final pass: apply alignment
    $result = if ($Justify -eq 'Left') {
        $renderables.ToArray()
    } else {
        $aligned = [System.Collections.Generic.List[object]]::new()
        foreach ($r in $renderables) {
            if ($r -is [Spectre.Console.Rule]) {
                $r.Justification = [Spectre.Console.Justify]::$Justify
                $aligned.Add($r)
            } else {
                $aligned.Add([Spectre.Console.Align]::$Justify($r))
            }
        }
        $aligned.ToArray()
    }

    } finally {
        $script:RecursionDepth--
    }
    return $result
}
