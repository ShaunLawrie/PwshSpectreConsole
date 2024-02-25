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
            Mock Invoke-SpectrePromptAsync {
                $Prompt | Should -BeOfType [Spectre.Console.SelectionPrompt[string]]
                $Prompt.Title | Should -Be $testTitle
                $Prompt.PageSize | Should -Be $testPageSize
                $Prompt.HighlightStyle.Foreground.ToMarkup() | Should -Be $testColor

                return $itemToBeSelectedName
            }
        }

        It "prompts" {
            Read-SpectreSelection -Title $testTitle -Choices (Get-RandomList) -PageSize $testPageSize -Color $testColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
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
        }
    }
}