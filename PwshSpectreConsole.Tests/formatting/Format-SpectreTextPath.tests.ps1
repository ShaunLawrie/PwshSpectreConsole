Describe "Format-SpectreTextPath" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [PwshSpectreConsole.Render.SpectreTextPath]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format a path" {
            $renderable = Format-SpectreTextPath -Path "C:\Windows\System32\cmd.exe"
            $renderable | Should -BeOfType [PwshSpectreConsole.Render.SpectreTextPath]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTextPath" -Output $testConsole.Output } | Should -Not -Throw
        }

        It "Should format with a custom format" {
            $renderable = Format-SpectreTextPath -Path "C:\Windows\System32\cmd.exe" -PathStyle @{
                RootColor      = [Spectre.Console.Color]::Cyan2
                SeparatorColor = [Spectre.Console.Color]::Aqua
                StemColor      = [Spectre.Console.Color]::Orange1
                LeafColor      = [Spectre.Console.Color]::HotPink
            }
            $renderable | Should -BeOfType [PwshSpectreConsole.Render.SpectreTextPath]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTextPathCustom" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
