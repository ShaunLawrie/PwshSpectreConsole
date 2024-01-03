Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreRule" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $color = Get-RandomColor
            $color | Out-Null
            $justification = Get-RandomJustify
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Rule] `
                -and $RenderableObject.Justification -eq $justification
            }
        }

        It "writes a rule" {
            Write-SpectreRule -Title (Get-RandomString) -Alignment $justification -Color $color
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}