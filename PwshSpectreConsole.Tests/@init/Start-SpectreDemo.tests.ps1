Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
try {
    Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
} catch {
    Write-Warning "Failed to import PwshSpectreConsole module, rebuilding..."
    & "$PSScriptRoot\..\..\PwshSpectreConsole\build.ps1"
}

Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force

Describe "Start-SpectreDemo" {
    InModuleScope "PwshSpectreConsole" {

        $script:recorder

        BeforeEach {
            #$writer = [System.IO.StringWriter]::new()
            #$output = [Spectre.Console.AnsiConsoleOutput]::new($writer)
            #$settings = [Spectre.Console.AnsiConsoleSettings]::new()
            #$settings.Out = $output
            #[Spectre.Console.AnsiConsole]::Console = [Spectre.Console.AnsiConsole]::Create($settings)
            $script:testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $script:recorder = [Spectre.Console.AnsiConsoleExtensions]::CreateRecorder($script:testConsole)

            Mock Read-SpectrePause { }
            Mock Clear-Host { }
        }

        AfterEach {
            $html = [Spectre.Console.RecorderExtensions]::ExportHtml($script:recorder)
            Set-Content -Path "$PSScriptRoot\..\@snapshots\$($____Pester.CurrentTest.Name).html" -Value ($html -replace "`r", "") -NoNewline

            $settings = [Spectre.Console.AnsiConsoleSettings]::new()
            $settings.Out = [Spectre.Console.AnsiConsoleOutput]::new([System.Console]::Out)
            [Spectre.Console.AnsiConsole]::Console = [Spectre.Console.AnsiConsole]::Create($settings)
        }

        It "Should have a demo function available, we're just testing the module was loaded correctly" {
            $demo = Get-Command Start-SpectreDemo
            $demo.Name | Should -Be "Start-SpectreDemo"   
        }
    }
}