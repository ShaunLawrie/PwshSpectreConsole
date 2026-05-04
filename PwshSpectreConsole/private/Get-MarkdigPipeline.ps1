<#
.SYNOPSIS
    Returns a cached Markdig MarkdownPipeline configured with common extensions.
.DESCRIPTION
    Builds the pipeline once per session and caches it in $script:MarkdigPipeline.
    Ensures Markdig.Signed.dll is loaded from $PSHOME if not already available.
    Extensions enabled: Advanced (tables, footnotes, task lists, definition lists, etc.).
#>
function Get-MarkdigPipeline {
    [CmdletBinding()]
    [OutputType([Markdig.MarkdownPipeline])]
    param()

    if (-not $script:MarkdigPipeline) {
        # Ensure Markdig is loaded. PowerShell 7+ includes Markdig.Signed.dll in $PSHOME.
        if (-not ("Markdig.MarkdownPipelineBuilder" -as [type])) {
            $dllPath = Join-Path $PSHOME 'Markdig.Signed.dll'
            if (Test-Path $dllPath) {
                Add-Type -Path $dllPath -ErrorAction SilentlyContinue
            } else {
                # Fallback to Markdig.dll if it exists (for older or custom PWSH builds)
                $dllPath = Join-Path $PSHOME 'Markdig.dll'
                if (Test-Path $dllPath) {
                    Add-Type -Path $dllPath -ErrorAction SilentlyContinue
                }
            }
        }

        # If it's still not loaded, this will throw a meaningful error when we try to use the type
        $builder = [Markdig.MarkdownPipelineBuilder]::new()

        # UseAdvancedExtensions enables: tables, footnotes, task lists,
        # definition lists, mathematics, citations, figures, media, etc.
        [void][Markdig.MarkdownExtensions]::UseAdvancedExtensions($builder)

        $script:MarkdigPipeline = $builder.Build()
    }

    return $script:MarkdigPipeline
}
