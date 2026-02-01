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
    $script:originalConsole = [Spectre.Console.AnsiConsole]::Console
}

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
