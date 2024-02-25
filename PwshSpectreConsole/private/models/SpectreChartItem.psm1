using namespace Spectre.Console

class SpectreChartItem
{
    [string] $Label
    [double] $Value
    [Color] $Color

    SpectreChartItem([string] $Label, [double] $Value, [Color] $Color) {
        $this.Label = $Label
        $this.Value = $Value
        $this.Color = $Color
    }
}