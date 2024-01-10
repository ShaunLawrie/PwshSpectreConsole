Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreCalendar" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
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

        It "writes calendar for a date" {
            $sample = Write-SpectreCalendar -Date "2024-01-01" -Culture "en-us" -Border $testBorder -Color $testColor
            $object = $sample -split '\r?\n'
            $object[0] | should -Match 'January\s+2024'
            $rawdays = $object[2]
            $days = $rawdays -split '\|' | Get-AnsiEscapeSequence | ForEach-Object {
                if (-Not [String]::IsNullOrWhiteSpace($_.Clean)) {
                    $_.Clean -replace '\s+'
                }
            }
            $days | Should -Be @('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "writes calendar for a date with events" {
            $events = @{
                '2022-03-10' = 'Event 1'
                '2022-03-20' = 'Event 2'
            }
            $sample = Write-SpectreCalendar -Date "2024-03-01" -Events $events -Culture "en-us" -Border Markdown -Color $testColor
            $sample.count | should -be 2
            $sample[0] | should -Match 'March\s+2024'
            $sample[1] | should -Match 'Event 1'
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 2 -Exactly
        }
        It "writes calendar for a date with events" {
            $sample = Write-SpectreCalendar -Date 2024-07-01 -HideHeader -Border Markdown -Color $testColor
            $object = $sample -split '\r?\n' | Select-Object -Skip 1 | Select-Object -SkipLast 3
            $object.count | should -be 7
            [string[]]$results = 1..31
            $object | Select-Object -Skip 2 | ForEach-Object {
                $_ -split '\|' | Get-AnsiEscapeSequence | ForEach-Object {
                    if (-Not [String]::IsNullOrWhiteSpace($_.Clean)) {
                        $_.Clean -replace '\s+' | should -BeIn $results
                    }
                }
            }
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }
    }
}
