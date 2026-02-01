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

Describe "Format-SpectreTree" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 140)
            $testGuide = Get-RandomTreeGuide
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Tree]
                $RenderableObject.Style.Foreground.ToMarkup() | Should -Be $testColor
                $RenderableObject.Guide.GetType().ToString() | Should -BeLike "*$testGuide*"
                $RenderableObject.Nodes.Count | Should -BeGreaterThan 0

                $testConsole.Write($RenderableObject)
            }
        }

        It "Should create a Tree" {
            $tree = Get-RandomTree | Format-SpectreTree -Guide $testGuide -Color $testColor
            $tree | Should -BeOfType [Spectre.Console.Tree]
            $tree | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testData = @{
                Value    = "Root"
                Children = @(
                    @{
                        Value    = "Child 1"
                        Children = @(
                            @{
                                Value    = "Grandchild 1"
                                Children = @(
                                    @{
                                        Value = "Great Grandchild 1"
                                    },
                                    @{
                                        Value = "Great Grandchild 2"
                                    },
                                    @{
                                        Value = "Great Grandchild 3"
                                    }
                                )
                            }
                        )
                    },
                    @{
                        Value = "Child 2"
                    }
                )
            }

            $testGuide = "BoldLine"
            $testColor = "DeepPink2"
            $tree = $testData | Format-SpectreTree -Guide $testGuide -Color $testColor
            $tree | Should -BeOfType [Spectre.Console.Tree]
            $tree | Out-SpectreHost
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTree" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
