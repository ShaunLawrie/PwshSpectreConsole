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
