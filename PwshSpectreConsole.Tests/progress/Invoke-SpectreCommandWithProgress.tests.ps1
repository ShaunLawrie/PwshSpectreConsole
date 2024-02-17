Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

$script:originalConsole = [Spectre.Console.AnsiConsole]::Console

Describe "Invoke-SpectreCommandWithProgress" -Tag "integration" {
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
            Invoke-SpectreCommandWithProgress -ScriptBlock {
                param (
                    $Context
                )
                $task1 = $Context.AddTask("Completing a single stage process")
                Start-Sleep -Milliseconds 500
                $task1.Increment(100)
                return 1
            } | Should -Be 1
        }

        It "executes the scriptblock with background jobs" {
            Invoke-SpectreCommandWithProgress -ScriptBlock {
                param (
                    $Context
                )
                $jobs = @()
                $jobs += Add-SpectreJob -Context $Context -JobName "job 1" -Job (Start-Job { Start-Sleep -Seconds 1 })
                $jobs += Add-SpectreJob -Context $Context -JobName "job 2" -Job (Start-Job { Start-Sleep -Seconds 1 })
                Wait-SpectreJobs -Context $Context -Jobs $jobs
                return 1
            } | Should -Be 1
        }
    }
}