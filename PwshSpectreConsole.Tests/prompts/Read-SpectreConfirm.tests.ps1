Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreConfirm" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testColor = Get-RandomColor
            $choices = @("y", "n")
            $answer = "y"
            Mock Invoke-SpectrePromptAsync -Verifiable -ParameterFilter {
                $Prompt -is [Spectre.Console.TextPrompt[string]] `
                -and $null -eq (Compare-Object -ReferenceObject $Prompt.Choices -DifferenceObject $choices) `
                -and (($testColor -eq $null -and $Prompt.Style.Foreground -eq $null) -or ($testColor -ne $null -and $Prompt.Style.Foreground.ToMarkup() -eq $testColor))
            } -MockWith {
                return $answer
            }
        }

        It "prompts" {
            Read-SpectreConfirm -Prompt (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts with a default answer" {
            $expectedAnswer = (Get-RandomChoice $choices)
            $thisAnswer = Read-SpectreConfirm -Prompt (Get-RandomString) -DefaultAnswer $thisAnswer
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
            $thisAnswer | Should -Be $expectedAnswer
        }

        It "writes success message" {
            $confirmSuccess = Get-RandomString
            Mock Write-SpectreHost -Verifiable -ParameterFilter {
                $Message -eq $confirmSuccess
            }
            Read-SpectreConfirm -Prompt (Get-RandomString) -ConfirmSuccess $confirmSuccess -DefaultAnswer (Get-RandomChoice $choices)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHost" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "writes failure message" {
            $confirmFailure = Get-RandomString
            $answer = "n"
            $answer | Out-Null
            Mock Write-SpectreHost -Verifiable -ParameterFilter {
                $Message -eq $confirmFailure
            }
            Read-SpectreConfirm -Prompt (Get-RandomString) -ConfirmFailure $confirmFailure -DefaultAnswer (Get-RandomChoice $choices)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHost" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "accepts color" {
            Read-SpectreConfirm -Prompt (Get-RandomString) -Color $testColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}