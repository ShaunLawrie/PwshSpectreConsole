Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreRule" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 140)
            $testColor = Get-RandomColor
            Write-Debug $testColor
            $justification = Get-RandomJustify
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rule]
                $RenderableObject.Justification | Should -Be $justification
                
                $testConsole.Write($RenderableObject)
            }
            
            # Mock our new function for width support
            Mock Write-AnsiConsoleWithWidth {
                param($RenderableObject, $MaxWidth)
                $RenderableObject | Should -BeOfType [Spectre.Console.Rule]
                $RenderableObject.Justification | Should -Be $justification
                
                # Return something for piping to Out-Host
                return "Rule with width $MaxWidth"
            }
            
            # Also mock Out-Host to prevent actual output to the console during tests
            Mock Out-Host { }
        }

        It "writes a rule" {
            $randomString = Get-RandomString
            Write-SpectreRule -Title $randomString -Alignment $justification -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testTitle = "yo, this is a test rule"
            $justification = "Center"
            $testColor = "Red"

            Write-SpectreRule -Title $testTitle -Alignment $justification -Color $testColor

            { Assert-OutputMatchesSnapshot -SnapshotName "Write-SpectreRule" -Output $testConsole.Output } | Should -Not -Throw
        }
        
        It "should write a rule with a specific width" {
            $testTitle = "Fixed Width Rule"
            $testWidth = 40
            
            Write-SpectreRule -Title $testTitle -Alignment $justification -Color $testColor -Width $testWidth
            
            Assert-MockCalled -CommandName "Write-AnsiConsoleWithWidth" -Times 1 -Exactly -ParameterFilter { 
                $MaxWidth -eq $testWidth 
            }
            Assert-MockCalled -CommandName "Out-Host" -Times 1 -Exactly
        }
        
        It "should write a rule with a percentage width" {
            $testTitle = "Half Width Rule"
            $testPercent = 50
            
            # Mock Console.WindowWidth to return a fixed value for testing
            Mock -CommandName Get-Variable -ParameterFilter { $Name -eq 'Host' } -MockWith {
                return @{
                    Value = @{
                        UI = @{
                            RawUI = @{
                                WindowSize = @{
                                    Width = 120
                                }
                            }
                        }
                    }
                }
            }
            
            Mock -CommandName Get-Member -ParameterFilter { $InputObject -eq [Console] -and $Name -eq 'WindowWidth' } -MockWith {
                return @{
                    Name = 'WindowWidth'
                    MemberType = 'Property'
                }
            }
            
            Mock -CommandName Get-Item -ParameterFilter { $Path -eq 'Variable:\Console' } -MockWith {
                return @{
                    Value = @{
                        WindowWidth = 120
                    }
                }
            }
            
            # Direct mock of [Console]::WindowWidth which doesn't work in Pester but demonstrates intent
            # Mock -CommandName [Console]::WindowWidth -MockWith { return 120 }
            
            $expectedWidth = [Math]::Floor(120 * ($testPercent / 100))
            
            # In a real scenario, we'd use:
            # [Console]::WindowWidth
            # But for the test, we'll just use 120 directly
            
            Write-SpectreRule -Title $testTitle -Alignment $justification -Color $testColor -WidthPercent $testPercent
            
            Assert-MockCalled -CommandName "Write-AnsiConsoleWithWidth" -Times 1 -Exactly
            Assert-MockCalled -CommandName "Out-Host" -Times 1 -Exactly
        }
    }
}