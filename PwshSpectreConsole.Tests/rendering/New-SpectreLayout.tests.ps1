Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "New-SpectreLayout" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should generate a layout" {
            $panel1 = "what" | Format-SpectrePanel -Header "panel 1 (align bottom right)" -Expand -Color Green
            $panel2 = "hello row 2" | Format-SpectrePanel -Header "panel 2" -Expand -Color Blue
            $panel3 = "test" | Format-SpectreAligned | Format-SpectrePanel -Header "panel 3 (align middle center)" -Expand -Color Yellow

            $row1 = New-SpectreLayout -Name "row1" -Data $panel1 -Ratio 1
            $row2 = New-SpectreLayout -Name "row2" -Columns @($panel2, $panel3) -Ratio 2
            $renderable = New-SpectreLayout -Name "root" -Rows @($row1, $row2)

            $renderable | Should -BeOfType [Spectre.Console.Layout]

            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "New-SpectreLayout" -Output $testConsole.Output } | Should -Not -Throw
            
        }
    }
}