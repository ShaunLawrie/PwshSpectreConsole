BeforeAll {
    if (-Not (Get-Module PwshSpectreConsole)) {
        if ($env:RunMergedPsm1Tests) {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'output' 'PwshSpectreConsole.psd1')
        }
        else {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'PwshSpectreConsole' 'PwshSpectreConsole.psd1')
        }
        Write-Host "Importing PwshSpectreConsole module from $ModulePath"
        Import-Module $ModulePath -ErrorAction Stop
    }
    if (-Not (Get-Module TestHelpers)) {
        $TestHelpersPath = Resolve-Path (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1')
        Import-Module $TestHelpersPath -ErrorAction Stop
    }
}

Describe "Read-SpectreText" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testAnswerColor = $null
            Mock Invoke-SpectrePromptAsync {
                $Prompt | Should -BeOfType [Spectre.Console.TextPrompt[string]]
                if ($Prompt.PromptStyle.Foreground) {
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
            Read-SpectreText -Message "What?" -AllowEmpty
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }

        It "can use a colored prompt" {
            $testAnswerColor = Get-RandomColor
            Read-SpectreText -Question (Get-RandomString) -AnswerColor $testAnswerColor
            Assert-MockCalled -CommandName "Invoke-SpectrePromptAsync" -Times 1 -Exactly
        }
    }
}
