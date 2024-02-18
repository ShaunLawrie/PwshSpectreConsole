Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreFigletText" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 180)
            $testColor = Get-RandomColor
            $testAlignment = Get-RandomJustify
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.FigletText]
                $RenderableObject.Justification | Should -Be $testAlignment
                $RenderableObject.Color.ToMarkup() | Should -Be $testColor
                
                $testConsole.Write($RenderableObject)
            }
        }

        It "writes figlet text" {
            Write-SpectreFigletText -Text (Get-RandomString) -Alignment $testAlignment -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "throws when the font file isn't found" {
            { Write-SpectreFigletText -FigletFontPath "notfound.flf" } | Should -Throw
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 0 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $testTitle = "f i glett"
            $testAlignment = "Center"
            $testColor = "DarkSeaGreen1_1"

            Write-SpectreFigletText -Text $testTitle -Alignment $testAlignment -Color $testColor

            $snapshotComparison = "$PSScriptRoot\..\@snapshots\Write-SpectreFigletText.snapshot.compare.txt"
            Set-Content -Path $snapshotComparison -Value ($testConsole.Output -replace "`r", "") -NoNewline
            $compare = Get-Content -Path $snapshotComparison -AsByteStream
            $snapshot = Get-Content -Path "$PSScriptRoot\..\@snapshots\Write-SpectreFigletText.snapshot.txt" -AsByteStream
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