Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreMultiSelection" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testTitle = Get-RandomString
            $testPageSize = Get-Random -Minimum 1 -Maximum 10
            $testColor = Get-RandomColor
            $itemsToBeSelectedNames = $null
            Mock Invoke-SpectrePromptAsync {
                $Prompt | Should -BeOfType [Spectre.Console.MultiSelectionPrompt[string]]
                $Prompt.Title | Should -Be $testTitle
                $Prompt.PageSize | Should -Be $testPageSize
                $Prompt.HighlightStyle.Foreground.ToMarkup() | Should -Be $testColor

                return $itemsToBeSelectedNames
            }
        }

        It "prompts and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $choices = (Get-RandomList) + $itemsToBeSelectedNames
            Read-SpectreMultiSelection -Title $testTitle -Choices $choices -PageSize $testPageSize -Color $testColor | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $choices = $itemsToBeSelectedNames + (Get-RandomList)
            Read-SpectreMultiSelection -Title $testTitle -Choices $choices -PageSize $testPageSize -Color $testColor | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "throws with duplicate labels" {
            { Read-SpectreMultiSelection -Title $testTitle -Choices @("same", "same") -PageSize $testPageSize -Color $testColor } | Should -Throw
        }

        It "throws with object choices without a ChoiceLabelProperty" {
            $choices = @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            )
            { Read-SpectreMultiSelection -Title $testTitle -Choices $choices -PageSize $testPageSize -Color $testColor } | Should -Throw
        }

        It "prompts with an object input and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            Read-SpectreMultiSelection -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $testPageSize -Color $testColor -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            ) | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts with an object input and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected",  "also to be selected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $anotherItemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[1]; Other = Get-RandomString }
            Read-SpectreMultiSelection -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $testPageSize -Color $testColor -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $anotherItemToBeSelected
            ) | Should -Be @($itemToBeSelected, $anotherItemToBeSelected)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}