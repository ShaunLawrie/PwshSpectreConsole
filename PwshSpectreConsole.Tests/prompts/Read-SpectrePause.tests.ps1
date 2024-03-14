Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Read-SpectrePause" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testMessage = $null
            Mock Write-SpectreHost -Verifiable -ParameterFilter { $Message -eq $testMessage }
            Mock Write-SpectreHost { }
            Mock Clear-InputQueue
            Mock Set-CursorPosition
            Mock Write-Host
            Mock Read-ConsoleKey {
                $enter = [System.ConsoleKey]::Enter
                return [System.ConsoleKeyInfo]::new([char]$enter.value__, $enter, $false, $false, $false)
            }
        }

        It "displays" {
            Read-SpectrePause
            Assert-MockCalled -CommandName "Read-ConsoleKey" -Times 1 -Exactly
        }

        It "displays a custom message" {
            $testMessage = Get-RandomString
            Write-Debug $testMessage
            Read-SpectrePause -Message $testMessage
            Assert-MockCalled -CommandName "Read-ConsoleKey" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}