Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force
# [Spectre.Console.AnsiConsole]::Profile | Out-Host
# [Spectre.Console.AnsiConsole]::Profile.Capabilities | Out-Host
# $PSStyle.OutputRendering | Out-Host
# probably need this
# $OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
Describe "ConvertTo-SpectreDecoration" {
    InModuleScope "PwshSpectreConsole" {
        <#
        # https://spectreconsole.net/api/spectre.console/colorsystem/
        # PSStyle colors wont work correctly because there is no way to get a 4bit color from Spectre
        It "Test PSStyle foreground" {
            # [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'Legacy' # Standard
            $PSStyleColor = Get-PSStyleRandom -Foreground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # $sample, $test | Get-AnsiEscapeSequence | Format-Table -AutoSize | Out-String | Write-Debug -Debug
            #if ((Get-SpectreProfile).Enrichers -eq 'GitHub') {
                # just fake it out for now, atleast checks something?
                (Get-AnsiEscapeSequence $test).Clean | should -Be (Get-AnsiEscapeSequence $sample).Clean
            #}
            #else {
               $test | should -Be $sample
            #}
        }
        It "Test PSStyle background" {
            # [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'Legacy'
            $PSStyleColor = Get-PSStyleRandom -background
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            $sample, $test | Get-AnsiEscapeSequence | Format-Table -AutoSize | Out-String | Write-Debug -Debug
            #if ((Get-SpectreProfile).Enrichers -eq 'GitHub') {
                # just fake it out for now, atleast checks something?
                # (Get-AnsiEscapeSequence $test).Clean | should -Be (Get-AnsiEscapeSequence $sample).Clean
            #}
            #else {
               $test | should -Be $sample
            #}
        }
        #>
        It "Test PSStyle Decorations" {
            $PSStyleColor = Get-PSStyleRandom -Decoration
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # $sample, $test | Get-AnsiEscapeSequence | Format-Table -AutoSize | Out-String | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test PSStyle Foreground RGB Colors" {
            # testing something
            [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'TrueColor'
            $PSStyleColor = Get-PSStyleRandom -RGBForeground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # $sample, $test | Get-AnsiEscapeSequence | Format-Table -AutoSize | Out-String | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test PSStyle Background RGB Colors" {
            [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'TrueColor'
            # Get-SpectreProfile | Out-Host
            $PSStyleColor = Get-PSStyleRandom -RGBBackground
            $reset = $PSStyle.Reset
            $string = 'Hello, world!, hello universe!'
            $sample = "{0}{1}{2}" -f $PSStyleColor, $string, $PSStyle.Reset
			$test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample)
            #   for debugging
            # $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $sample -Debug)
            # $sample, $test | Get-AnsiEscapeSequence | Format-Table -AutoSize | Out-String | Write-Debug -Debug
            $test | should -Be $sample
        }
        It "Test Spectre Colors" {
            [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'TrueColor'
            $sample = Get-SpectreColorSample
            foreach ($item in $sample) {
                $test = Get-SpectreRenderable (ConvertTo-SpectreDecoration $item.String)
                $test | Should -Be $item.String
            }
        }
    }
}
