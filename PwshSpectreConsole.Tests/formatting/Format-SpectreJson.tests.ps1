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
                    Name = "John"
                    Age = 25
                    City = "New York"
                    IsEmployed = $true
                    Salary = 10
                    Hobbies = @("Reading", "Swimming")
                    Address = [pscustomobject]@{
                        Street = "123 Main St"
                        City = "New York"
                        Deep = @{
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
                        State = "NY"
                        Zip = "10001"
                    }
                }
            )
            $testData | Out-Null
            $testConsole | Out-Null
            $testBorder = Get-RandomBoxBorder
            $testColor = Get-RandomColor
            $testTitle = Get-RandomString
            $testExpand = Get-RandomBool
            $testWidth = Get-Random -Minimum 5 -Maximum 100
            $testHeight = Get-Random -Minimum 5 -Maximum 100
            Write-Debug $testBorder
            Write-Debug $testColor
            Write-Debug $testTitle
            Write-Debug $testExpand
            Write-Debug $testWidth
            Write-Debug $testHeight

            Mock Get-HostWidth { return 100 }
            Mock Get-HostHeight { return 100 }
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
        }

        It "tries to render a panel which somewhat implies that the json parsing worked" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Panel]
                $RenderableObject.Header.Text | Should -Be $testTitle
                if($testBorder -ne "None") {
                    $RenderableObject.Border.GetType().Name | Should -BeLike "*$testBorder*"
                }
                $RenderableObject.BorderStyle.Foreground.ToMarkup() | Should -Be $testColor
                $RenderableObject.Width | Should -Be $testWidth
                $RenderableObject.Height | Should -Be $testHeight
                $RenderableObject.Expand | Should -Be $testExpand

                $testConsole.Write($RenderableObject)
            }

            Format-SpectreJson -Title $testTitle -Border $testBorder -Color $testColor -Height $testHeight -Width $testWidth -Expand:$testExpand -Data $testData
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "tries to render json when noborder is specified" {
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Json.JsonText]
            }

            Format-SpectreJson -NoBorder -Data $testData
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Simple scalar array test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                1..$numbers | Format-SpectreJson -Border None
                $json = $testConsole.Output | StripAnsi
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }

        It "Simple String test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                1..$numbers | ConvertTo-Json | Format-SpectreJson -Border None
                $json = $testConsole.Output | StripAnsi
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }

        It "Should take json string input" {
            $data = @(
                [pscustomobject]@{Name = "John"; Age = 25; City = "New York" },
                [pscustomobject]@{Name = "Jane"; Age = $null; City = "Los Angeles" }
            )
            $data | ConvertTo-Json | Format-SpectreJson -Border None
            $roundtrip = $testConsole.Output | StripAnsi | ConvertFrom-Json
            (Compare-Object -ReferenceObject $data -DifferenceObject $roundtrip -Property Name, Age, City -CaseSensitive -IncludeEqual).SideIndicator | Should -Be @('==','==')
        }
        
        It "Should roundtrip json string input" {
            $ht = @{}
            Get-RandomList -MinItems 30 -MaxItems 50 | ForEach-Object {
                $ht[$_] = Get-RandomString
            }
            $data = [pscustomobject]$ht
            $data | ConvertTo-Json | Format-SpectreJson -Border None
            $roundtrip = $testConsole.Output | StripAnsi | ConvertFrom-Json
            $roundtrip.psobject.properties.name | Should -Be $data.psobject.properties.name
            $roundtrip.psobject.properties.value | Should -Be $data.psobject.properties.value
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            Format-SpectreJson -Title "Test title" -Border "Double" -Color "SpringGreen3" -Height 25 -Width 78 -Data $testData
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreJson" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}