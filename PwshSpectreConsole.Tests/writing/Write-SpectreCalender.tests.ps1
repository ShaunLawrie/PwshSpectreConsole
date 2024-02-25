Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreCalendar" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            
            $testBorder = 'Markdown'
            $testColor = Get-RandomColor
            Write-Debug $testBorder
            Write-Debug $testColor
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
        }

        It "writes calendar for a date" {
            Write-SpectreCalendar -Date "2024-01-01" -Culture "en-us" -Border $testBorder -Color $testColor
            $sample = $testConsole.Output
            $object = $sample -split '\r?\n'
            $object[0] | Should -Match 'January\s+2024'
            $rawdays = $object[2]
            $days = $rawdays -split '\|' | Get-AnsiEscapeSequence | ForEach-Object {
                if (-Not [String]::IsNullOrWhiteSpace($_.Clean)) {
                    $_.Clean -replace '\s+'
                }
            }
            $answer = (Get-Culture -Name en-us).DateTimeFormat.AbbreviatedDayNames
            # $days | Should -Be @('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')
            $days | Should -Be $answer
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "writes calendar for a date with events" {
            $events = @{
                '2022-03-10' = 'Event 1'
                '2022-03-20' = 'Event 2'
            }
            Write-SpectreCalendar -Date "2024-03-01" -Events $events -Culture "en-us" -Border Markdown -Color $testColor
            $sample = $testConsole.Output
            $sample | Should -Match 'March\s+2024'
            $sample | Should -Match 'Event 1'
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 2 -Exactly
        }

        It "writes calendar for a date with something else going on" {
            Write-SpectreCalendar -Date 2024-07-01 -HideHeader -Border Markdown -Color $testColor
            $sample = $testConsole.Output
            $object = $sample -split '\r?\n' | Select-Object -Skip 1 -SkipLast 3
            $object.count | Should -Be 7
            [string[]]$results = 1..31
            $object | Select-Object -Skip 2 | ForEach-Object {
                $_ -split '\|' | Get-AnsiEscapeSequence | ForEach-Object {
                    if (-Not [String]::IsNullOrWhiteSpace($_.Clean)) {
                        $_.Clean -replace '\s+' | Should -BeIn $results
                    }
                }
            }
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $events = @{
                '2022-03-10' = 'Event 1'
                '2022-03-20' = 'Event 2'
            }
            $culture = Get-Culture -Name "en-US"
            Write-SpectreCalendar -Date 2024-07-01 -Culture $culture -Events $events -Border "Rounded" -Color "SpringGreen3"
            { Assert-OutputMatchesSnapshot -SnapshotName "Write-SpectreCalendar" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
