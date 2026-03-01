Describe "Start-SpectreDemo" {
    InModuleScope "PwshSpectreConsole" {
        It "Should have a demo function available, we're just testing the module was loaded correctly" {
            Get-Command "Start-SpectreDemo" | Should -Not -BeNullOrEmpty
        }
    }
}
