Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTree" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testGuide = Get-RandomTreeGuide
            $testColor = Get-RandomColor
            
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Tree]
                $RenderableObject.Style.Foreground.ToMarkup() | Should -Be $testColor
                $RenderableObject.Guide.GetType().ToString() | Should -BeLike "*$testGuide*"
                $RenderableObject.Nodes.Count | Should -BeGreaterThan 0

                $testConsole.Write($RenderableObject)
            }
        }

        It "Should create a Tree" {
            Get-RandomTree | Format-SpectreTree -Guide $testGuide -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}