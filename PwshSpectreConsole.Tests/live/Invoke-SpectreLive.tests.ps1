Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Invoke-SpectreLive" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
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
            $table = @{ Name = "Test"; Value = "Value" } | Format-SpectreTable
            Invoke-SpectreLive -Data $table -ScriptBlock {
                param (
                    $Context
                )
                return 1
            } | Should -Be 1
        }

        It "executes the scriptblock with background jobs" {
            Mock Start-AnsiConsoleLive {
                $Data | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $ScriptBlock | Should -BeOfType [scriptblock]

                & $ScriptBlock
            }

            $table = @{ Name = "Test"; Value = "Value" } | Format-SpectreTable
            Invoke-SpectreLive -Data $table -ScriptBlock {
                param (
                    $Context
                )
                return 1
            } | Should -Be 1
        }
        
    }
}