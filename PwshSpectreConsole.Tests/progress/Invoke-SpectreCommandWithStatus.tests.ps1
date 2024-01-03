Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Invoke-SpectreCommandWithStatus" -Tag "integration" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testTitle = Get-RandomString
            $testSpinner = Get-RandomSpinner
            $testColor = Get-RandomColor
            $testTitle | Out-Null
            $testSpinner | Out-Null
            $testColor | Out-Null
        }

        It "executes the scriptblock for the basic case" {
            Mock Start-AnsiConsoleStatus -Verifiable -ParameterFilter {
                $Title -eq $testTitle `
                -and $Spinner.GetType().Name -like "*$testSpinner*" `
                -and $SpinnerStyle.Foreground.ToMarkup() -eq $testColor `
                -and $ScriptBlock -is [scriptblock]
            } -MockWith {
                & $ScriptBlock
            }
            Invoke-SpectreCommandWithStatus -Title $testTitle -Spinner $testSpinner -Color $testColor -ScriptBlock {
                return 1
            } | Should -Be 1
            Assert-MockCalled -CommandName "Start-AnsiConsoleStatus" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "executes the scriptblock without mocking" {
            Invoke-SpectreCommandWithStatus -Title $testTitle -Spinner $testSpinner -Color $testColor -ScriptBlock {
                Start-Sleep -Seconds 1
                return 1
            } | Should -Be 1
        }
    }
}