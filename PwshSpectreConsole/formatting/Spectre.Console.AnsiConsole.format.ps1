# TODO - Ask @startautomating how this can be done better
Write-FormatView -TypeName "Spectre.Console.Rendering.Renderable" -Action {
    $_ | Out-SpectreHost -CustomItemFormatter
}