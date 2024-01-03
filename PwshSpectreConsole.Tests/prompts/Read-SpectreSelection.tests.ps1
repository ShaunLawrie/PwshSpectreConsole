Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreSelection" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $title = Get-RandomString
            $pageSize = Get-Random -Minimum 1 -Maximum 10
            $color = Get-RandomColor
            $itemToBeSelectedName = $null
            Mock Invoke-SpectrePromptAsync -Verifiable -ParameterFilter {
                $Prompt -is [Spectre.Console.SelectionPrompt[string]] `
                -and $Prompt.Title -eq $title `
                -and $Prompt.PageSize -eq $pageSize `
                -and $Prompt.HighlightStyle.Foreground.ToMarkup() -eq $color 
            } -MockWith {
                return $itemToBeSelectedName
            }
        }

        It "prompts" {
            Read-SpectreSelection -Title $title -Choices (Get-RandomList) -PageSize $pageSize -Color $color
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "throws with duplicate labels" {
            { Read-SpectreSelection -Title $title -Choices @("same", "same") -PageSize $pageSize -Color $color } | Should -Throw
        }

        It "prompts with an object input" {
            $itemToBeSelectedName = Get-RandomString
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemToBeSelectedName; Other = Get-RandomString }
            Read-SpectreSelection -Title $title -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $pageSize -Color $color -Choices @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            ) | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}