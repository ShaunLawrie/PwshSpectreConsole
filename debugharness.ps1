$sb = {
    param($s)
    Push-Location $s
    & ./build.ps1 -Task 'Repro'
    Import-Module ./output/PwshSpectreConsole.psd1
    $img = Get-Item './PwshSpectreConsole/private/images/smiley.png'
    [int] $size = $host.UI.RawUI.WindowSize.Width / 4 - 5
    'Image : {0}, Size: {1}' -f $img.Name, $size
    $col = @(
        Format-SpectreColumns @(
            (Get-SpectreImage -ImagePath $img.FullName -Width $size -Format Sixel)
            'Sixel Format'
        )
        Format-SpectreColumns @(
            (Get-SpectreImage -ImagePath $img.FullName -Width $size -Format Blocks)
            'Blocks Format'
        )
        Format-SpectreColumns @(
            (Get-SpectreImage -ImagePath $img.FullName -Width $size -Format Braille)
            'Braille Format'
        )
        Format-SpectreColumns @(
            (Get-SpectreImage -ImagePath $img.FullName -Width $size -Format Canvas)
            'Canvas Format'
        )
    ) | Format-SpectrePanel
    New-SpectreLayout -Columns $col
}
pwsh -nop -c $sb -args $PSScriptRoot
