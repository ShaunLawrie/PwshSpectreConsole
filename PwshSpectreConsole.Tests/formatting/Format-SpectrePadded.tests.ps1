Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectrePadded" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format data with padding around it" {
            $renderable = "Item to pad" | Format-SpectrePadded -Padding 6
            $renderable | Should -BeOfType [Spectre.Console.Padder]
            $renderable.Padding.Top | Should -Be 6
            $renderable.Padding.Left | Should -Be 6
            $renderable.Padding.Bottom | Should -Be 6
            $renderable.Padding.Right | Should -Be 6
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should format data with padding around it with specific padding values" {
            $renderable = "Item to pad" | Format-SpectrePadded -Top 4 -Left 10 -Right 1 -Bottom 1
            $renderable | Should -BeOfType [Spectre.Console.Padder]
            $renderable.Padding.Top | Should -Be 4
            $renderable.Padding.Left | Should -Be 10
            $renderable.Padding.Bottom | Should -Be 1
            $renderable.Padding.Right | Should -Be 1
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should format data with padding around it with expanded padding" {
            $renderable = "Item to pad" | Format-SpectrePadded -Top 4 -Left 10 -Right 1 -Bottom 1 | Format-SpectrePanel
            $renderable | Should -BeOfType [Spectre.Console.Panel]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectrePadded" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}