# TODO - Ask @startautomating how this can be done better
Write-FormatView -TypeName "Spectre.Console.Rendering.Renderable" -Action {
    # Work out if the current object is being piped to another command, there isn't access to the pipeline in the format view script block so it's using a janky regex workaround
    try {
        $line = $MyInvocation.Line
        $start = $MyInvocation.OffsetInLine
        $lineAfterOffset = $line.SubString($start, ($line.Length - $start))
        $targetIsInPipeline = $lineAfterOffset | Select-String "^[^;]+?\|"
        $pipelineSegment = $lineAfterOffset | Select-String "^[^;]+?(;|$)" | Select-Object -ExpandProperty Matches -First 1 | Select-Object -ExpandProperty Value
        $targetIsPipedToSpectreFunction = $pipelineSegment -match ".*\|.*(Write|Format|Out)-Spectre.*"
        Write-Debug "Line: $line"
        Write-Debug "Start: $start"
        Write-Debug "Line after offset: $lineAfterOffset"
        Write-Debug "Target is in pipeline: $targetIsInPipeline"
        Write-Debug "Pipeline segment: $pipelineSegment"
        Write-Debug "Target is piped to Spectre function: $targetIsPipedToSpectreFunction"
    } catch {
        Write-Debug "Failed to discover pipeline state for Spectre.Console.Rendering.Renderable: $_"
    }

    if ($targetIsInPipeline -and -not $targetIsPipedToSpectreFunction) {
        $_
    } else {
        $_ | Out-SpectreHost
    }
}