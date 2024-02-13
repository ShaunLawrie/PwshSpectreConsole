Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreJson" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testData = $null
            $testBorder = 'Markdown'
            $testColor = Get-RandomColor
            Mock Write-AnsiConsole {
                param(
                    [Parameter(Mandatory)]
                    [Spectre.Console.Rendering.Renderable] $RenderableObject
                )
                try {
                    $writer = [System.IO.StringWriter]::new()
                    $output = [Spectre.Console.AnsiConsoleOutput]::new($writer)
                    $settings = [Spectre.Console.AnsiConsoleSettings]::new()
                    $settings.Out = $output
                    $console = [Spectre.Console.AnsiConsole]::Create($settings)
                    $console.Write($RenderableObject)
                    $writer.ToString()
                }
                finally {
                    $writer.Dispose()
                }
            }
        }
        It "Simple scalar array test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                $json = 1..$numbers | Format-SpectreJson -Border None
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }
        It "Simple String test" {
            {
                $numbers = Get-Random -Minimum 30 -Maximum 50
                $json = 1..$numbers | ConvertTo-Json | Format-SpectreJson -Border None
                ($json.trim() -split "\r?\n").count | Should -Be ($numbers + 2) # 10 items + 2 braces
            } | Should -Not -Throw
        }
        It "Should take json string input" {
            $data = @(
                [pscustomobject]@{Name = "John"; Age = 25; City = "New York" },
                [pscustomobject]@{Name = "Jane"; Age = $null; City = "Los Angeles" }
            )
            $roundtrip = $data | ConvertTo-Json | Format-SpectreJson -Border None | StripAnsi | ConvertFrom-Json
            (Compare-Object -ReferenceObject $data -DifferenceObject $roundtrip -Property Name, Age, City -CaseSensitive -IncludeEqual).SideIndicator | Should -Be @('==','==')
        }
        It "Should roundtrip json string input" {
            $ht = @{}
            Get-RandomList -MinItems 30 -MaxItems 50 | ForEach-Object {
                $ht[$_] = Get-RandomString
            }
            $data = [pscustomobject]$ht
            $roundtrip = $data | ConvertTo-Json | Format-SpectreJson -Border None | StripAnsi | ConvertFrom-Json
            $roundtrip.psobject.properties.name | Should -Be $data.psobject.properties.name
            $roundtrip.psobject.properties.value | Should -Be $data.psobject.properties.value
        }
    }
}
