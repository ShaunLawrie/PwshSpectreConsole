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
