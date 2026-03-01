Describe "Format-SpectreAligned" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should align an item" {
            $renderable = "testing" | Format-SpectreAligned -HorizontalAlignment Right
            $renderable | Should -BeOfType [Spectre.Console.Align]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should align an item in a panel horizontally and vertically" {
            $renderable = "testing panel" | Format-SpectreAligned -HorizontalAlignment Center -VerticalAlignment Middle | Format-SpectrePanel -Height 7 -Expand
            $renderable | Should -BeOfType [Spectre.Console.Panel]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreAligned" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
