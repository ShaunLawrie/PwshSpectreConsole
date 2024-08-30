Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreGrid" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format data in a grid" {
            $rows = 4
            $cols = 6
            
            $gridRows = @()
            for ($row = 1; $row -le $rows; $row++) {
                $columns = @()
                for ($col = 1; $col -le $cols; $col++) {
                    $columns += "Row $row, Col $col"
                }
                $gridRows += New-SpectreGridRow $columns
            }
            
            $renderable = $gridRows | Format-SpectreGrid
            $renderable | Should -BeOfType [Spectre.Console.Grid]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreGrid" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}