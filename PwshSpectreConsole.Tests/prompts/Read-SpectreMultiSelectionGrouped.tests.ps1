Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreMultiSelectionGrouped" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $title = Get-RandomString
            $pageSize = Get-Random -Minimum 1 -Maximum 10
            $color = Get-RandomColor
            $itemsToBeSelectedNames = $null
            Mock Invoke-SpectrePromptAsync -Verifiable -ParameterFilter {
                $Prompt -is [Spectre.Console.MultiSelectionPrompt[string]] `
                -and $Prompt.Title -eq $title `
                -and $Prompt.PageSize -eq $pageSize `
                -and $Prompt.HighlightStyle.Foreground.ToMarkup() -eq $color 
            } -MockWith {
                return $itemsToBeSelectedNames
            }
        }

        It "prompts and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $choices = @(Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = Get-RandomList
                }
            })
            $choices += @{
                Name = "Group with selection"
                Choices = @(Get-RandomList) + $itemsToBeSelectedNames
            }
            Read-SpectreMultiSelectionGrouped -Title $title -Choices $choices -PageSize $pageSize -Color $color | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $choices = @(Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = "toBeSelected" + (Get-RandomList)
                }
            })
            $choices += @{
                Name = "Group with selection"
                Choices = @(Get-RandomList) + "also to be selected"
            }
            Read-SpectreMultiSelectionGrouped -Title $title -Choices $choices -PageSize $pageSize -Color $color | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "throws with duplicate labels" {
            { Read-SpectreMultiSelectionGrouped -Title $title -Choices @("same", "same") -PageSize $pageSize -Color $color } | Should -Throw
        }

        It "throws with object choices and no ChoiceLabelProperty" {
            $choices = Get-RandomList -Generator {
                return @{
                    Name = Get-RandomString
                    Choices = (Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    })
                }
            }
            { Read-SpectreMultiSelectionGrouped -Title $title -Choices $choices -PageSize $pageSize -Color $color } | Should -Throw
        }

        It "prompts with an object input and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $choices = @(
                @{
                    Name = Get-RandomString
                    Choices = @(Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    }) + $itemToBeSelected
                }
            )
            Read-SpectreMultiSelectionGrouped -Title $title -ChoiceLabelProperty "ColumnToSelectFrom" -Choices $choices -PageSize $pageSize -Color $color | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts with an object input and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $anotherItemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[1]; Other = Get-RandomString }
            $choices = @(
                @{
                    Name = Get-RandomString
                    Choices = @($itemToBeSelected) + (Get-RandomList -Generator {
                        [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
                    }) + $anotherItemToBeSelected
                }
            )
            Read-SpectreMultiSelectionGrouped -Title $title -ChoiceLabelProperty "ColumnToSelectFrom" -Choices $choices -PageSize $pageSize -Color $color | Should -Be @($itemToBeSelected, $anotherItemToBeSelected)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}