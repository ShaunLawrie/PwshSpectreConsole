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

        It "accepts pipeline input for choices" {
            $itemToBeSelectedName = Get-RandomString
            $choices = @($itemToBeSelectedName) + (Get-RandomList)
            $choices | Read-SpectreSelection -Title $testTitle -PageSize $testPageSize -Color $testColor | Should -Be $itemToBeSelectedName
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "accepts pipeline input for object choices with ChoiceLabelProperty" {
            $itemToBeSelectedName = Get-RandomString
            $itemToBeSelected = [PSCustomObject]@{ ColumnToSelectFrom = $itemToBeSelectedName; Other = Get-RandomString }
            $choices = @(
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString },
                $itemToBeSelected,
                [PSCustomObject]@{ ColumnToSelectFrom = Get-RandomString; Other = Get-RandomString }
            )
            $choices | Read-SpectreSelection -Title $testTitle -ChoiceLabelProperty "ColumnToSelectFrom" -PageSize $testPageSize -Color $testColor | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts with a scriptblock ChoiceLabelProperty" {
            $itemToBeSelectedName = "hello_42"
            $itemToBeSelected = [PSCustomObject]@{ Name = "hello"; Id = 42 }
            Read-SpectreSelection -Title $testTitle -ChoiceLabelProperty { "$($_.Name)_$($_.Id)" } -PageSize $testPageSize -Color $testColor -Choices @(
                [PSCustomObject]@{ Name = "foo"; Id = 1 },
                $itemToBeSelected,
                [PSCustomObject]@{ Name = "bar"; Id = 2 }
            ) | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "accepts pipeline input with a scriptblock ChoiceLabelProperty" {
            $itemToBeSelectedName = "hello_42"
            $itemToBeSelected = [PSCustomObject]@{ Name = "hello"; Id = 42 }
            $choices = @(
                [PSCustomObject]@{ Name = "foo"; Id = 1 },
                $itemToBeSelected,
                [PSCustomObject]@{ Name = "bar"; Id = 2 }
            )
            $choices | Read-SpectreSelection -Title $testTitle -ChoiceLabelProperty { "$($_.Name)_$($_.Id)" } -PageSize $testPageSize -Color $testColor | Should -Be $itemToBeSelected
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}
