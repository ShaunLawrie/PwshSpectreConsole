using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreMarkdown {
    <#
    .SYNOPSIS
    Renders a Markdown string to the terminal using Spectre.Console widgets.

    .DESCRIPTION
    Parses Markdown via Markdig and maps block-level elements to Spectre.Console
    renderables: headings to Rules, paragraphs to Markup, fenced code to Panels,
    tables to Tables, blockquotes to bordered Panels, and lists to styled Markup.

    Inline formatting (bold, italic, inline code, links) is preserved throughout.

    Images are shown as [image: alt text] placeholders by default. Use -IncludeImages
    to render them via Get-SpectreImage (canvas or Sixel depending on terminal support).
    Remote http/https URLs are downloaded automatically. Relative paths are resolved
    against -ImageBasePath (defaults to the current directory).

    This function relies on the Markdig library included with PowerShell 7+ ($PSHOME\Markdig.Signed.dll).

    .PARAMETER Markdown
    The Markdown string to render. Accepts pipeline input.

    .PARAMETER Title
    Wraps the entire output in a Spectre Panel with this title.

    .PARAMETER PassThru
    Returns the array of Spectre.Console IRenderable objects instead of writing to the console. Useful for composing into larger layouts.

    .PARAMETER IncludeImages
    Render images inline using Get-SpectreImage instead of showing a placeholder.

    .PARAMETER ImageMaxWidth
    Maximum width in characters for rendered images. 0 (default) means no limit.

    .PARAMETER ImageBasePath
    Base directory used to resolve relative image paths. Defaults to the current directory.

    .PARAMETER Justify
    Aligns all block-level output. Defaults to 'Left'.

    .PARAMETER Center
    Centers the output. Shortcut for -Justify Center.

    .PARAMETER Border
    The type of border to be displayed around the panel when Title is provided. Defaults to 'Rounded'.

    .PARAMETER Color
    The color of the panel border when Title is provided. Defaults to the module's accent color.

    .PARAMETER Expand
    Switch parameter that specifies whether the panel should be expanded to fill the available space when Title is provided.

    .PARAMETER Padding
    The padding to use inside the panel when Title is provided. Defaults to 1 (left/right).

    .EXAMPLE
    # **Example 1**
    # This example demonstrates how to render a basic Markdown string.
    "# Hello World`n`nThis is **bold** and *italic*." | Format-SpectreMarkdown

    .EXAMPLE
    # **Example 2**
    # This example demonstrates how to render a multi-line Markdown string with a table.
    $markdown = "## Results`n`n| Name | Value |`n| --- | --- |`n| Foo | 1 |`n| Bar | 2 |"
    $markdown | Format-SpectreMarkdown

    .EXAMPLE
    # **Example 3**
    # This example demonstrates how to use PassThru to get renderables for composition.
    $renderables = "## Section`n`nSome text." | Format-SpectreMarkdown -PassThru

    .EXAMPLE
    # **Example 4**
    # This example demonstrates how to wrap the output in a titled panel.
    $markdown = "This is a **response** with _formatted_ text.`n`n- Item one`n- Item two"
    Format-SpectreMarkdown -Markdown $markdown -Title "AI Response" -Color Green

    .EXAMPLE
    # **Example 5**
    # This example demonstrates how to render an image inline using IncludeImages.
    $markdown = "![Smiley](.\private\images\smiley.png)`n`nCaption below the image."
    $markdown | Format-SpectreMarkdown -IncludeImages -ImageMaxWidth 25
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/formatting/format-spectremarkdown/')]
    [Reflection.AssemblyMetadata("title", "Format-SpectreMarkdown")]
    [Alias('fsm')]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [string]$Markdown,
        [string]$Title,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string]$Border = "Rounded",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color]$Color,
        [switch]$Expand,
        [int]$Padding = 1,
        [switch]$PassThru,
        [switch]$IncludeImages,
        [int]$ImageMaxWidth = 0,
        [string]$ImageBasePath,
        [ValidateSet('Left', 'Center', 'Right')]
        [string]$Justify = 'Left',
        [switch]$Center
    )

    begin {
        if ($Center) { $Justify = 'Center' }
        $chunks = [System.Collections.Generic.List[string]]::new()
    }

    process {
        # Collect all pipeline input — Markdig works best on the full document
        $chunks.Add($Markdown)
    }

    end {
        $fullMarkdown = $chunks -join "`n"

        # Parse
        $pipeline = Get-MarkdigPipeline
        $document = [Markdig.Markdown]::Parse($fullMarkdown, $pipeline)

        # Convert blocks → Spectre renderables
        $blockParams = @{
            Container = $document
            Justify   = $Justify
        }
        if ($IncludeImages) {
            $blockParams.IncludeImages  = $true
            $blockParams.ImageMaxWidth  = $ImageMaxWidth
            $blockParams.ImageBasePath  = if ($ImageBasePath) { $ImageBasePath } else { $PWD.Path }
        }
        $renderables = Convert-MarkdigBlockToRenderable @blockParams

        # Optionally wrap in a Panel
        if ($PSBoundParameters.ContainsKey('Title') -and $Title) {
            $panel = [Spectre.Console.Panel]::new(
                [Spectre.Console.Rows]::new($renderables)
            )
            $panel.Header      = [Spectre.Console.PanelHeader]::new("[bold]$Title[/]")
            $panel.Border      = [Spectre.Console.BoxBorder]::$Border
            $panel.Expand      = $Expand
            $panel.Padding     = [Spectre.Console.Padding]::new($Padding, 0)
            $panel.BorderStyle = [Spectre.Console.Style]::new(
                ($PSBoundParameters.ContainsKey('Color') ? $Color : $script:AccentColor)
            )
            $renderables = @($panel)
        }

        if ($PassThru) {
            return $renderables
        }

        foreach ($renderable in $renderables) {
            Write-AnsiConsole -RenderableObject $renderable
        }
    }
}
