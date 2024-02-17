Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTree" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testGuide = Get-RandomTreeGuide
            $testColor = Get-RandomColor
            
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Tree] `
                -and $RenderableObject.Style.Foreground.ToMarkup() -eq $testColor `
                -and $RenderableObject.Guide.GetType().ToString() -like "*$testGuide*" `
                -and $RenderableObject.Nodes.Count -gt 0
            }
        }

        It "Should create a Tree" {
            Get-RandomTree | Format-SpectreTree -Guide $testGuide -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}