Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreSelection" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testTitle = Get-RandomString
            $testPageSize = Get-Random -Minimum 1 -Maximum 10
            $testColor = Get-RandomColor
            $itemToBeSelectedName = $null
            Mock Invoke-SpectrePromptAsync -Verifiable -ParameterFilter {
                $Prompt -is [Spectre.Console.SelectionPrompt[string]] `
                -and $Prompt.Title -eq $testTitle `
                -and $Prompt.PageSize -eq $testPageSize `
                -and $Prompt.HighlightStyle.Foreground.ToMarkup() -eq $testColor 
            } -MockWith {
                return $itemToBeSelectedName
            }
        }

        It "prompts" {
            Read-SpectreSelection -Title $testTitle -Choices (Get-RandomList) -PageSize $testPageSize -Color $testColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "throws with duplicate labels" {
            { Read-SpectreSelection -Title $testTitle -Choices @("same", "same") -PageSize $testPageSize -Color $testColor } | Should -Throw
        }

        It "prompts with an object input" {
            $itemToBeSelectedName = Get-RandomString
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemToBeSelectedName; Other = Get-RandomString }
            Read-SpectreSelection -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $testPageSize -Color $testColor -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            ) | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}