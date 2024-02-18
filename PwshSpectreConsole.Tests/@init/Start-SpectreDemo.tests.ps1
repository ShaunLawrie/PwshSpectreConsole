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

        It "Should have a demo function available, we're just testing the module was loaded correctly" {
            Get-Command "Start-SpectreDemo" | Should -Not -BeNullOrEmpty
        }
    }
}