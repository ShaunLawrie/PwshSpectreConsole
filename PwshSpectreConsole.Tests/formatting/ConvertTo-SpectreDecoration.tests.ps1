BeforeAll {
    if (-Not (Get-Module PwshSpectreConsole)) {
        if ($env:RunMergedPsm1Tests) {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'output' 'PwshSpectreConsole.psd1')
        }
        else {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'PwshSpectreConsole' 'PwshSpectreConsole.psd1')
        }
        Write-Host "Importing PwshSpectreConsole module from $ModulePath"
        Import-Module $ModulePath -ErrorAction Stop
    }
    if (-Not (Get-Module TestHelpers)) {
        $TestHelpersPath = Resolve-Path (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1')
        Import-Module $TestHelpersPath -ErrorAction Stop
    }
    # [Spectre.Console.AnsiConsole]::Profile.Capabilities.ColorSystem = 'Standard'
    # $script:SpectreConsole.Profile.Capabilities.ColorSystem = 'Standard'
}

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
        # colors get upscaled.. they match visually in the console but the codes differ...
        # It "Test Spectre Colors" {
        #     # this might work because the colors are generated from CI so shouldnt get us codes we cant render.
        #     $sample = Get-SpectreColorSample
        #     foreach ($item in $sample) {
        #         $test = Get-SpectreRenderable ([PwshSpectreConsole.VTParser]::ToParagraph($item.String))
        #         $test | Should -Be $item.String
        #     }
        # }
    }
}
