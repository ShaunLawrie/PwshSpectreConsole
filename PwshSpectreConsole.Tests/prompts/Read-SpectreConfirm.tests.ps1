Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreConfirm" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $choices = @("y", "n")
            $testDefaultAnswer = "y"
            Mock Invoke-SpectrePromptAsync {
                $Prompt | Should -BeOfType [Spectre.Console.TextPrompt[string]]
                (Compare-Object -ReferenceObject $Prompt.Choices -DifferenceObject $choices) | Should -BeNullOrEmpty
                if($testColor) {
                    $Prompt.ChoicesStyle.Foreground.ToMarkup() | Should -Be $testColor
                }
                return $testDefaultAnswer
            }
        }

        It "prompts" {
            Read-SpectreConfirm -Prompt (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts with a default answer" {
            $testDefaultAnswer = Get-RandomChoice $choices
            $expectedAnswer = ($testDefaultAnswer -eq "y") ? $true : $false
            $thisAnswer = Read-SpectreConfirm -Prompt (Get-RandomString) -DefaultAnswer $testDefaultAnswer
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            $thisAnswer | Should -Be $expectedAnswer
        }

        It "writes success message" {
            $confirmSuccess = Get-RandomString
            Mock Write-SpectreHost {
                $Message | Should -Be $confirmSuccess
            }
            Read-SpectreConfirm -Prompt (Get-RandomString) -ConfirmSuccess $confirmSuccess -DefaultAnswer (Get-RandomChoice $choices)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHost" -Times 1 -Exactly
        }

        It "writes failure message" {
            $confirmFailure = Get-RandomString
            $testDefaultAnswer = "n"
            $testDefaultAnswer | Out-Null
            Mock Write-SpectreHost {
                $Message | Should -Be $confirmFailure
            }
            Read-SpectreConfirm -Prompt (Get-RandomString) -ConfirmFailure $confirmFailure -DefaultAnswer (Get-RandomChoice $choices)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHost" -Times 1 -Exactly
        }

        It "accepts color" {
            $testColor = Get-RandomColor
            Read-SpectreConfirm -Prompt (Get-RandomString) -Color $testColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}