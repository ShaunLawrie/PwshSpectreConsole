class SpectreChartItem
{
    [string] $Label
    [double] $Value
    [string] $Color

    SpectreChartItem([string] $Label, [double] $Value, [string] $Color) {
        $this.Label = $Label
        $this.Value = $Value
        $this.Color = $Color
    }
}