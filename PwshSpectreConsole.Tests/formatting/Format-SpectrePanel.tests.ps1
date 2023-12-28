Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectrePanel" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $title = Get-RandomString
            $border = Get-RandomBoxBorder
            $expand = Get-RandomBool
            $color = Get-RandomColor

            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Panel] `
                -and ($border -eq "None" -or $RenderableObject.Border.GetType().Name -like "*$border*") `
                -and $RenderableObject.Header.Text -eq $title `
                -and $RenderableObject.Expand -eq $expand `
                -and $RenderableObject.BorderStyle.Foreground.ToMarkup() -eq $color
            }
        }

        It "Should create a panel" {
            Format-SpectrePanel -Data (Get-RandomString) -Title $title -Border $border -Expand:$expand -Color $color
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}