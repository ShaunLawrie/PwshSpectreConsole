Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectreText" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testAnswerColor = $null
            Mock Invoke-SpectrePromptAsync {
                $Prompt | Should -BeOfType [Spectre.Console.TextPrompt[string]]
                if($Prompt.PromptStyle.Foreground) {
                    $Prompt.PromptStyle.Foreground.ToMarkup() | Should -Be $testAnswerColor
                }
            }
        }

        It "prompts" {
            Read-SpectreText -Question (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "prompts with a default answer" {
            Read-SpectreText -Question (Get-RandomString) -DefaultAnswer (Get-RandomString)
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "can allow an empty answer" {
            Read-SpectreText -AllowEmpty
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "can use a colored prompt" {
            $testAnswerColor = Get-RandomColor
            Read-SpectreText -Question (Get-RandomString) -AnswerColor $testAnswerColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}