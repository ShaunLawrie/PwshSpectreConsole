Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTable" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testData = $null
            $testBorder = "None" #Get-RandomBoxBorder
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole {
                if($RenderableObject -isnot [Spectre.Console.Table]) {
                    throw "Found $($RenderableObject.GetType().Name), expected [Spectre.Console.Table]"
                }
                $borderType = ($testBorder -eq "None") ? "NoTableBorder" : $testBorder
                if($RenderableObject.Border.GetType().Name -notlike "*$borderType*") {
                    throw "Found $($RenderableObject.Border.GetType().Name), expected border like *$borderType*"
                }
                if($RenderableObject.BorderStyle.Foreground.ToMarkup() -ne $testColor) {
                    throw "Found $($RenderableObject.BorderStyle.Foreground.ToMarkup()), expected $testColor"
                }
                if($RenderableObject.Rows.Count -ne $testData.Count) {
                    throw "Found $($RenderableObject.Rows.Count), expected $($testData.Count)"
                }
                Write-Debug "Input data was $($RenderableObject.Rows.Count) rows, $($RenderableObject.Columns.Count) columns, border $($RenderableObject.BorderStyle.Foreground.ToMarkup()), borderstyle, $($RenderableObject.BorderStyle.GetType().Name)"
            }
        }

        It "Should create a table when default display members for a command are required" {
            $testData = Get-ChildItem "$PSScriptRoot"
            Format-SpectreTable -Data $testData -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}