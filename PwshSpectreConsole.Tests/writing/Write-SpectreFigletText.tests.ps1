Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreFigletText" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testColor = Get-RandomColor
            $testAlignment = Get-RandomJustify
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.FigletText] `
                -and $RenderableObject.Justification -eq $testAlignment `
                -and $RenderableObject.Color.ToMarkup() -eq $testColor
            }
        }

        It "writes figlet text" {
            Write-SpectreFigletText -Text (Get-RandomString) -Alignment $testAlignment -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "throws when the font file isn't found" {
            { Write-SpectreFigletText -FigletFontPath "notfound.flf" } | Should -Throw
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 0 -Exactly
        }
    }
}