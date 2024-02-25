Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreMultiSelectionGrouped" {
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
            $testChoices = @(Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = Get-RandomList
                }
            })
            $testChoices += @{
                Name = "Group with selection"
                Choices = @(Get-RandomList) + $itemsToBeSelectedNames
            }
            Read-SpectreMultiSelectionGrouped -Title $testTitle -Choices $testChoices -PageSize $testPageSize -Color $testColor | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $testChoices = @(Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = "toBeSelected" + (Get-RandomList)
                }
            })
            $testChoices += @{
                Name = "Group with selection"
                Choices = @(Get-RandomList) + "also to be selected"
            }
            Read-SpectreMultiSelectionGrouped -Title $testTitle -Choices $testChoices -PageSize $testPageSize -Color $testColor | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "throws with duplicate labels" {
            { Read-SpectreMultiSelectionGrouped -Title $testTitle -Choices @("same", "same") -PageSize $testPageSize -Color $testColor } | Should -Throw
        }

        It "throws with object choices and no ChoiceLabelProperty" {
            $testChoices = Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = (Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    })
                }
            }
            { Read-SpectreMultiSelectionGrouped -Title $testTitle -Choices $testChoices -PageSize $testPageSize -Color $testColor } | Should -Throw
        }

        It "prompts with an object input and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $testChoices = @(
                @{
                    Name = Get-RandomString
                    Choices = @(Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    }) + $itemToBeSelected
                }
            )
            Read-SpectreMultiSelectionGrouped -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -Choices $testChoices -PageSize $testPageSize -Color $testColor | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts with an object input and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $anotherItemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[1]; Other = Get-RandomString }
            $testChoices = @(
                @{
                    Name = Get-RandomString
                    Choices = @($itemToBeSelected) + (Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    }) + $anotherItemToBeSelected
                }
            )
            Read-SpectreMultiSelectionGrouped -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -Choices $testChoices -PageSize $testPageSize -Color $testColor | Should -Be @($itemToBeSelected, $anotherItemToBeSelected)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}