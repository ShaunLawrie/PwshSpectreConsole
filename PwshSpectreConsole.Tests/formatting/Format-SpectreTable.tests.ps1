Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTable" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $data = 0..(Get-Random -Minimum 4 -Maximum 25) | Foreach-Object {
                Get-RandomString
            }
            $border = Get-RandomBoxBorder
            $color = Get-RandomColor

            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Table] `
                -and ($border -eq "None" -or $RenderableObject.Border.GetType().Name -like "*$border*") `
                -and $RenderableObject.BorderStyle.Foreground.ToMarkup() -eq $color `
                -and $RenderableObject.Rows.Count -eq $data.Count
            }
        }

        It "Should create a Table" {
            Format-SpectreTable -Data $data -Border $border -Color $color
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}