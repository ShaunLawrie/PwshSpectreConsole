Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreJson" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testData = @(
                [pscustomobject]@{
                    Name = "John"
                    Age = 25
                    City = "New York"
                    IsEmployed = $true
                    Salary = 10
                    Hobbies = @("Reading", "Swimming")
                    Address = @{
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
            $data | Out-Null
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
        }

        It "tries to render a panel which somewhat implies that the json parsing worked" {
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Panel] `
                -and ($null -eq $testTitle -or $RenderableObject.Header.Text -eq $testTitle) `
                -and ($null -eq $testBorder -or "None" -eq $testBorder -or $RenderableObject.Border.GetType().Name -like "*$testBorder*") `
                -and ($null -eq $testColor -or $RenderableObject.BorderStyle.Foreground.ToMarkup() -eq $testColor) `
                -and ($null -eq $testWidth -or $RenderableObject.Width -eq $testWidth) `
                -and ($null -eq $testHeight -or $RenderableObject.Height -eq $testHeight) `
                -and ($null -eq $testExpand -or $RenderableObject.Expand -eq $testExpand)
            }

            Format-SpectreJson -Title $testTitle -Border $testBorder -Color $testColor -Height $testHeight -Width $testWidth -Expand:$testExpand -Data $testData
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "tries to render json when noborder is specified" {
            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Json.JsonText]
            }

            Format-SpectreJson -NoBorder -Data $testData
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}