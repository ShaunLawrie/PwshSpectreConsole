Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "ConvertTo-SpectreDecoration" {
    InModuleScope "PwshSpectreConsole" {
        It "Test PSStyle Decorations" {
            $PSStyleColor = Get-PSStyleRandom -Decoration
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            $test | Should -Be $sample
        }
        It "Test PSStyle Foreground RGB Colors" -Tag "ExcludeCI" {
            # testing something
            $PSStyleColor = Get-PSStyleRandom -RGBForeground
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            $test | Should -Be $sample
        }
        It "Test PSStyle Background RGB Colors" -Tag "ExcludeCI" {
            $PSStyleColor = Get-PSStyleRandom -RGBBackground
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            $test | Should -Be $sample
        }
        It "Test Spectre Colors" {
            # this might work because the colors are generated from CI so shouldnt get us codes we cant render.
            $sample = Get-SpectreColorSample
            foreach ($item in $sample) {
                $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $item.String)
                $test | Should -Be $item.String
            }
        }
    }
}
