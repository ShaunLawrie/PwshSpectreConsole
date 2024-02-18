Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

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
            Get-RandomTree | Format-SpectreTree -Guide $testGuide -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testData = @{
                Label = "Root"
                Children = @(
                    @{
                        Label = "Child 1"
                        Children = @(
                            @{
                                Label = "Grandchild 1"
                                Children = @(
                                    @{
                                        Label = "Great Grandchild 1"
                                    },
                                    @{
                                        Label = "Great Grandchild 2"
                                    },
                                    @{
                                        Label = "Great Grandchild 3"
                                    }
                                )
                            }
                        )
                    },
                    @{
                        Label = "Child 2"
                    }
                )
            }

            $testGuide = "BoldLine"
            $testColor = "DeepPink2"
            $testData | Format-SpectreTree -Guide $testGuide -Color $testColor
            $snapshotComparison = "$PSScriptRoot\..\@snapshots\Format-SpectreTree.snapshot.compare.txt"
            Set-Content -Path $snapshotComparison -Value ($testConsole.Output -replace "`r", "") -NoNewline
            $compare = Get-Content -Path $snapshotComparison -AsByteStream
            $snapshot = Get-Content -Path "$PSScriptRoot\..\@snapshots\Format-SpectreTree.snapshot.txt" -AsByteStream
            try {
                $snapshot | Should -Be $compare
            } catch {
                # byte array to string
                Write-Host "Expected:`n`n$([System.Text.Encoding]::UTF8.GetString($snapshot))"
                Write-Host "Got:`n`n$([System.Text.Encoding]::UTF8.GetString($compare))"
                throw
            }
        }
    }
}