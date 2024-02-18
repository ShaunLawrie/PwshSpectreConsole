Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreHost" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testMessage = Get-RandomString
            $testMessage | Out-Null
            Mock Write-SpectreHostInternalMarkup
            Mock Write-SpectreHostInternalMarkupLine
        }

        It "writes a message" {
            Mock Write-SpectreHostInternalMarkupLine -Verifiable -ParameterFilter {
                $Message -eq $testMessage
            }
            Write-SpectreHost -Message $testMessage
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkupLine" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkup" -Times 0 -Exactly
        }

        It "accepts pipeline input" {
            Mock Write-SpectreHostInternalMarkupLine -Verifiable -ParameterFilter {
                $Message -eq $testMessage
            }
            $testMessage | Write-SpectreHost
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkupLine" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkup" -Times 0 -Exactly
        }

        It "handles nonewline" {
            Mock Write-SpectreHostInternalMarkup -Verifiable -ParameterFilter {
                $Message -eq $testMessage
            }
            Write-SpectreHost -Message $testMessage -NoNewline
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkup" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkupLine" -Times 0 -Exactly
        }
    }
}