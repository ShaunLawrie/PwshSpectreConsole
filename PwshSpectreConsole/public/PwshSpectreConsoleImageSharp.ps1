function Get-SpectreImage {
    param (
        [string] $ImagePath,
        [int] $MaxWidth
    )
    $image = [Spectre.Console.CanvasImage]::new($ImagePath)
    if($MaxWidth) {
        $image.MaxWidth = $MaxWidth
    }
    [Spectre.Console.AnsiConsole]::Write($image)
}