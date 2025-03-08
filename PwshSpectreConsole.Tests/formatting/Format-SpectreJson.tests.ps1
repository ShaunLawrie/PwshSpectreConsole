Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreJson" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            $testData = @(
                [pscustomobject]@{
                    Name       = "John"
                    Age        = 25
                    City       = "New York"
                    IsEmployed = $true
                    Salary     = 10
                    Hobbies    = @("Reading", "Swimming")
                    Address    = [pscustomobject]@{
                        Street = "123 Main St"
                        City   = "New York"
                        Deep   = @{
                            Nested = @{
                                Value = @{
                                    That = @{
                                        Is = @{
                                            Nested = @{
                                                Again = "Hello"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        State  = "NY"
                        Zip    = "10001"
                    }
                }
            )
            $testData | Out-Null
            $testConsole | Out-Null

            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
        }

        It "tries to render a json" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Json.JsonText]
                $testConsole.Write($RenderableObject)
            }

            $json = Format-SpectreJson -Data $testData
            $json | Should -BeOfType [Spectre.Console.Json.JsonText]
            $json | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Simple scalar array test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                1..$numbers | Format-SpectreJson | Out-SpectreHost
                $json = $testConsole.Output | StripAnsi
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }

        It "Simple String test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                1..$numbers | ConvertTo-Json | Format-SpectreJson | Out-SpectreHost
                $json = $testConsole.Output | StripAnsi
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }

        It "Should take json string input" {
            $data = @(
                [pscustomobject]@{Name = "John"; Age = 25; City = "New York" },
                [pscustomobject]@{Name = "Jane"; Age = $null; City = "Los Angeles" }
            )
            $data | ConvertTo-Json | Format-SpectreJson | Out-SpectreHost
            $roundtrip = $testConsole.Output | StripAnsi | ConvertFrom-Json
            (Compare-Object -ReferenceObject $data -DifferenceObject $roundtrip -Property Name, Age, City -CaseSensitive -IncludeEqual).SideIndicator | Should -Be @('==', '==')
        }
        
        It "Should roundtrip json string input" {
            $ht = @{}
            Get-RandomList -MinItems 30 -MaxItems 50 | ForEach-Object {
                $ht[$_] = Get-RandomString
            }
            $data = [pscustomobject]$ht
            $data | ConvertTo-Json | Format-SpectreJson | Out-SpectreHost
            $roundtrip = $testConsole.Output | StripAnsi | ConvertFrom-Json
            $roundtrip.psobject.properties.name | Should -Be $data.psobject.properties.name
            $roundtrip.psobject.properties.value | Should -Be $data.psobject.properties.value
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $json = Format-SpectreJson -Data $testData
            $json | Should -BeOfType [Spectre.Console.Json.JsonText]
            $json | Out-SpectreHost
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreJson" -Output $testConsole.Output } | Should -Not -Throw
        }

        It "Should format with a custom format" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Json.JsonText]
                $testConsole.Write($RenderableObject)
            }
            $json = Format-SpectreJson -Data $testData -JsonStyle @{
                MemberStyle    = [Spectre.Console.Color]::Cyan1
                BracesStyle    = [Spectre.Console.Color]::Cyan1
                BracketsStyle  = [Spectre.Console.Color]::Orange1
                ColonStyle     = [Spectre.Console.Color]::Cyan1
                CommaStyle     = [Spectre.Console.Color]::Cyan1
                StringStyle    = [Spectre.Console.Color]::White
                NumberStyle    = [Spectre.Console.Color]::Cyan1
                BooleanStyle   = [Spectre.Console.Color]::LightSkyBlue1
                NullStyle      = [Spectre.Console.Color]::Grey
            }
            $json | Should -BeOfType [Spectre.Console.Json.JsonText]
            $json | Out-SpectreHost
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreJsonCustom" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}