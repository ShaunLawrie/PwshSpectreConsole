Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectrePause" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $customMessage = $null
            Mock Write-SpectreHost -Verifiable -ParameterFilter {
                [string]::IsNullOrEmpty($customMessage) -or ($Message -eq $customMessage)
            }
            Mock Clear-InputQueue
            Mock Set-CursorPosition
            Mock Write-Host
            Mock Read-Host
        }

        It "displays" {
            Read-SpectrePause
            Assert-MockCalled -CommandName "Read-Host" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "displays a custom message" {
            $customMessage = Get-RandomString
            $customMessage | Out-Null
            Read-SpectrePause -Message $customMessage
            Assert-MockCalled -CommandName "Read-Host" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}