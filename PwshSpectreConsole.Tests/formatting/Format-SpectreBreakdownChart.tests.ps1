Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreBreakdownChart" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testWidth = Get-Random -Minimum 10 -Maximum 100
            $testData = @()
            for($i = 0; $i -lt (Get-Random -Minimum 3 -Maximum 10); $i++) {
                $testData += Get-RandomChartItem
            }

            Mock Write-AnsiConsole -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Rendering.Renderable] `
                -and $RenderableObject.Width -eq $testWidth `
                -and $RenderableObject.Data.Count -eq $testData.Count
            }

            Mock Get-HostWidth {
                return $testWidth
            }
        }

        It "Should create a bar chart with correct width" {
            Format-SpectreBreakdownChart -Data $testData -Width $testWidth
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
        
        It "Should handle piped input correctly" {
            $testData | Format-SpectreBreakdownChart -Width $testWidth
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
        
        It "Should handle single input correctly" {
            $testData = New-SpectreChartItem -Label (Get-RandomString) -Value (Get-Random -Minimum -100 -Maximum 100) -Color (Get-RandomColor)
            Format-SpectreBreakdownChart -Data $testData -Width $testWidth
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "Should handle no width and default to host width" {
            Mock Write-AnsiConsole -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Rendering.Renderable] `
                -and $RenderableObject.Width -eq $testWidth `
                -and $RenderableObject.Label -eq $null `
                -and $RenderableObject.Data.Count -eq $testData.Count
            }
            Format-SpectreBreakdownChart -Data $testData
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}