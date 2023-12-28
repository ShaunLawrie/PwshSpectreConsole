Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTree" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $treeGuide = Get-RandomTreeGuide
            $color = Get-RandomColor
            
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Tree] `
                -and $RenderableObject.Style.Foreground.ToMarkup() -eq $color `
                -and $RenderableObject.Guide.GetType().ToString() -like "*$treeGuide*" `
                -and $RenderableObject.Nodes.Count -gt 0
            }
        }

        It "Should create a Tree" {
            Get-RandomTree | Format-SpectreTree -Guide $treeGuide -Color $color
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}