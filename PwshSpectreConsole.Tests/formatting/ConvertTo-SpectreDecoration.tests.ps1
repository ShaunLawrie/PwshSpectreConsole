Describe "ConvertTo-SpectreDecoration" {
    InModuleScope "PwshSpectreConsole" {
        It "Test PSStyle Decorations" {
            $PSStyleColor = Get-PSStyleRandom -Decoration
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable ([PwshSpectreConsole.VTParser]::ToParagraph($sample))
            $test | Should -Be $sample
        }
        It "Test PSStyle Foreground RGB Colors" -Tag "ExcludeCI" {
            # testing something
            $PSStyleColor = Get-PSStyleRandom -RGBForeground
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable ([PwshSpectreConsole.VTParser]::ToParagraph($sample))
            $test | Should -Be $sample
        }
        It "Test PSStyle Background RGB Colors" -Tag "ExcludeCI" {
            $PSStyleColor = Get-PSStyleRandom -RGBBackground
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
            $test = Get-SpectreRenderable ([PwshSpectreConsole.VTParser]::ToParagraph($sample))
            $test | Should -Be $sample
        }
    }
}
