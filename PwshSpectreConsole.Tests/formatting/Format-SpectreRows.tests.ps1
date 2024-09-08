Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreRows" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format an array of strings into rows" {
            $renderable = Format-SpectreRows -Data @("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit,", "sed", "do", "eiusmod",
                "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua.", "Ut", "enim", "ad", "minim",
                "veniam,", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea",
                "commodo", "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit",
                "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "excepteur", "sint", "occaecat",
                "cupidatat", "non", "proident", "sunt", "in", "culpa")
            $renderable | Should -BeOfType [Spectre.Console.Rows]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreRows" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}