Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreText" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testAnswerColor = $null
            Mock Invoke-SpectrePromptAsync -Verifiable -ParameterFilter {
                $Prompt -is [Spectre.Console.TextPrompt[string]] `
                -and ($null -eq $Prompt.PromptStyle.Foreground -or $Prompt.PromptStyle.Foreground.ToMarkup() -eq $testAnswerColor)
            }
        }

        It "prompts" {
            Read-SpectreText -Question (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "prompts with a default answer" {
            Read-SpectreText -Question (Get-RandomString) -DefaultAnswer (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "can allow an empty answer" {
            Read-SpectreText -AllowEmpty
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "can use a colored prompt" {
            $testAnswerColor = Get-RandomColor
            Read-SpectreText -Question (Get-RandomString) -AnswerColor $testAnswerColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}