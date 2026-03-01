BeforeAll {
    if (-Not (Get-Module PwshSpectreConsole)) {
        $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'output' 'PwshSpectreConsole.psd1')
        Write-Host "Importing PwshSpectreConsole module from $ModulePath"
        Import-Module $ModulePath -ErrorAction Stop
    }
    if (-Not (Get-Module TestHelpers)) {
        $TestHelpersPath = Resolve-Path (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1')
        Import-Module $TestHelpersPath -ErrorAction Stop
    }
}
Describe "Format-SpectreBarChart" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            $testWidth = Get-Random -Minimum 10 -Maximum 100
            $testTitle = "Test Chart $([guid]::NewGuid())"
            $testData = @()
            for ($i = 0; $i -lt (Get-Random -Minimum 3 -Maximum 10); $i++) {
                $testData += New-SpectreChartItem -Label (Get-RandomString) -Value (Get-Random -Minimum -100 -Maximum 100) -Color (Get-RandomColor)
            }

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $RenderableObject.Width | Should -Be $testWidth
                $RenderableObject.Label | Should -Be $testTitle
                $RenderableObject.Data.Count | Should -Be $testData.Count

                $testConsole.Write($RenderableObject)
            }

            Mock Get-HostWidth {
                return $testWidth
            }
        }

        It "Should create a bar chart with correct width" {
            $chart = Format-SpectreBarChart -Data $testData -Title $testTitle -Width $testWidth
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should handle piped input correctly" {
            $chart = $testData | Format-SpectreBarChart -Title $testTitle -Width $testWidth
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should handle single input correctly" {
            $testData = New-SpectreChartItem -Label (Get-RandomString) -Value (Get-Random -Minimum -100 -Maximum 100) -Color (Get-RandomColor)
            $chart = Format-SpectreBarChart -Data $testData -Title $testTitle -Width $testWidth
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should handle no title" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $RenderableObject.Width | Should -Be $testWidth
                $RenderableObject.Label | Should -Be $null
                $RenderableObject.Data.Count | Should -Be $testData.Count

                $testConsole.Write($RenderableObject)
            }
            $chart = Format-SpectreBarChart -Data $testData -Width $testWidth
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should handle no width and default to host width" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $RenderableObject.Width | Should -Be $testWidth
                $RenderableObject.Label | Should -Be $null
                $RenderableObject.Data.Count | Should -Be $testData.Count

                $testConsole.Write($RenderableObject)
            }
            $chart = Format-SpectreBarChart -Data $testData
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testWidth = 120
            Write-Debug "Setting test width to $testWidth"
            $testData = @(
                (New-SpectreChartItem -Label "Test 1" -Value 10 -Color "Turquoise2"),
                (New-SpectreChartItem -Label "Test 2" -Value 20 -Color "#ff0000"),
                (New-SpectreChartItem -Label "Test 3" -Value 30 -Color "Turquoise2")
            )
            $chart = Format-SpectreBarChart -Data $testData
            $chart | Should -BeOfType [Spectre.Console.BarChart]
            $chart | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreBarChart" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
