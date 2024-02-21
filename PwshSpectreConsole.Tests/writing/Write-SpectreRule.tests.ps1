Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreRule" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 140)
            $testColor = Get-RandomColor
            Write-Debug $testColor
            $justification = Get-RandomJustify
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rule]
                $RenderableObject.Justification | Should -Be $justification
                
                $testConsole.Write($RenderableObject)
            }
        }

        It "writes a rule" {
            $randomString = Get-RandomString
            Write-SpectreRule -Title $randomString -Alignment $justification -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testTitle = "yo, this is a test rule"
            $justification = "Center"
            $testColor = "Red"

            Write-SpectreRule -Title $testTitle -Alignment $justification -Color $testColor

            { Assert-OutputMatchesSnapshot -SnapshotName "Write-SpectreRule" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}