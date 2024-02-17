Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectrePanel" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testTitle = Get-RandomString
            $testBorder = Get-RandomBoxBorder
            $testExpand = $false
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Panel] `
                -and ($testBorder -eq "None" -or $RenderableObject.Border.GetType().Name -like "*$testBorder*") `
                -and $RenderableObject.Header.Text -eq $testTitle `
                -and $RenderableObject.Expand -eq $testExpand `
                -and $RenderableObject.BorderStyle.Foreground.ToMarkup() -eq $testColor
            }
        }

        It "Should create a panel" {
            Format-SpectrePanel -Data (Get-RandomString) -Title $testTitle -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "Should create an expanded panel" {
            $testExpand = $true
            Format-SpectrePanel -Data (Get-RandomString) -Title $testTitle -Border $testBorder -Expand:$testExpand -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}