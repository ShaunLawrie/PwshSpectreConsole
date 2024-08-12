class SpectreChartItem {
    [string] $Label
    [double] $Value
    [Spectre.Console.Color] $Color

    SpectreChartItem([string] $Label, [double] $Value, [Spectre.Console.Color] $Color) {
        $this.Label = $Label
        $this.Value = $Value
        $this.Color = $Color
    }
}