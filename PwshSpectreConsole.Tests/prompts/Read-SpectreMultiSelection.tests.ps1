Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreMultiSelection" {
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
            $choices = (Get-RandomList) + $itemsToBeSelectedNames
            Read-SpectreMultiSelection -Title $title -Choices $choices -PageSize $pageSize -Color $color | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected", "also to be selected")
            $choices = $itemsToBeSelectedNames + (Get-RandomList)
            Read-SpectreMultiSelection -Title $title -Choices $choices -PageSize $pageSize -Color $color | Should -Be $itemsToBeSelectedNames
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "throws with duplicate labels" {
            { Read-SpectreMultiSelection -Title $title -Choices @("same", "same") -PageSize $pageSize -Color $color } | Should -Throw
        }

        It "throws with object choices without a ChoiceLabelProperty" {
            $choices = @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            )
            { Read-SpectreMultiSelection -Title $title -Choices $choices -PageSize $pageSize -Color $color } | Should -Throw
        }

        It "prompts with an object input and allows selection" {
            $itemsToBeSelectedNames = @("toBeSelected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            Read-SpectreMultiSelection -Title $title -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $pageSize -Color $color -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            ) | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts with an object input and allows multiple selection" {
            $itemsToBeSelectedNames = @("toBeSelected",  "also to be selected")
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[0]; Other = Get-RandomString }
            $anotherItemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemsToBeSelectedNames[1]; Other = Get-RandomString }
            Read-SpectreMultiSelection -Title $title -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $pageSize -Color $color -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $anotherItemToBeSelected
            ) | Should -Be @($itemToBeSelected, $anotherItemToBeSelected)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}