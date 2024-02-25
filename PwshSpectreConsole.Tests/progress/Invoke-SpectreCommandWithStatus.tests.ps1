Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Invoke-SpectreCommandWithStatus" -Tag "integration" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testTitle = Get-RandomString
            $testSpinner = Get-RandomSpinner
            $testColor = Get-RandomColor
            Write-Debug $testTitle
            Write-Debug $testSpinner
            Write-Debug $testColor

            $writer = [System.IO.StringWriter]::new()
            $output = [Spectre.Console.AnsiConsoleOutput]::new($writer)
            $settings = [Spectre.Console.AnsiConsoleSettings]::new()
            $settings.Out = $output
            [Spectre.Console.AnsiConsole]::Console = [Spectre.Console.AnsiConsole]::Create($settings)
        }

        AfterEach {
            $settings = [Spectre.Console.AnsiConsoleSettings]::new()
            $settings.Out = [Spectre.Console.AnsiConsoleOutput]::new([System.Console]::Out)
            [Spectre.Console.AnsiConsole]::Console = [Spectre.Console.AnsiConsole]::Create($settings)
        }

        It "executes the scriptblock for the basic case" {
            Mock Start-AnsiConsoleStatus {
                $Title | Should -Be $testTitle
                $Spinner.GetType().Name | Should -BeLike "*$testSpinner*"
                $SpinnerStyle.Foreground.ToMarkup() | Should -Be $testColor
                $ScriptBlock | Should -BeOfType [scriptblock]

                & $ScriptBlock
            }
            Invoke-SpectreCommandWithStatus -Title $testTitle -Spinner $testSpinner -Color $testColor -ScriptBlock {
                return 1
            } | Should -Be 1
            Assert-MockCalled -CommandName "Start-AnsiConsoleStatus" -Times 1 -Exactly
        }

        It "executes the scriptblock without mocking" {
            Invoke-SpectreCommandWithStatus -Title $testTitle -Spinner $testSpinner -Color $testColor -ScriptBlock {
                Start-Sleep -Seconds 1
                return 1
            } | Should -Be 1
        }
    }
}