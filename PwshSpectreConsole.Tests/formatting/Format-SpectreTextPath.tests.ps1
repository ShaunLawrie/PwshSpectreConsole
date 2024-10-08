Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTextPath" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.TextPath]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format a path" {
            $renderable = Format-SpectreTextPath -Path "C:\Windows\System32\cmd.exe"
            $renderable | Should -BeOfType [Spectre.Console.TextPath]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTextPath" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}