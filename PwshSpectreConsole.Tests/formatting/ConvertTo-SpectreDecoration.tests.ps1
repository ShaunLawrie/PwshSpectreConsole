Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "ConvertTo-SpectreDecoration" {
    InModuleScope "PwshSpectreConsole" {
        <#
            # this fails, need to look into it.
        It "Test psstyle Foreground" {
            $PSStyleColor = Get-PSStyleRandom -Foreground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # ($test | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            # ($sample | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test psstyle background" {
            $PSStyleColor = Get-PSStyleRandom -background
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # ($test | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            # ($sample | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test psstyle Foreground" {
            $PSStyleColor = Get-PSStyleRandom -decorations
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # ($test | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            # ($sample | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            $test | should -Be $sample
        }
        #>
        It "Test psstyle Foreground rgb colors" {
            $PSStyleColor = Get-PSStyleRandom -RGBForeground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # ($test | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            # ($sample | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test psstyle Background rgb colors" {
            $PSStyleColor = Get-PSStyleRandom -RGBBackground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # ($test | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            # ($sample | Get-AnsiEscapeSequence).Decoded | Write-Debug -Debug
            $test | should -Be $sample
        }
    }
}
