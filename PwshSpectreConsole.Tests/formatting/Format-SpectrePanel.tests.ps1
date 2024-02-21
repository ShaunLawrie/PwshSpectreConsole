Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectrePanel" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 80)
            $testTitle = Get-RandomString -MinimumLength 5 -MaximumLength 10
            $testBorder = Get-RandomBoxBorder
            $testExpand = $false
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Panel]
                $RenderableObject.Header.Text | Should -Be $testTitle
                $RenderableObject.Expand | Should -Be $testExpand
                $RenderableObject.BorderStyle.Foreground.ToMarkup() | Should -Be $testColor
                if($testBorder -ne "None") {
                    $RenderableObject.Border.GetType().Name | Should -BeLike "*$testBorder*"
                }

                $testConsole.Write($RenderableObject)
            }
        }

        It "Should create a panel" {
            $randomString = Get-RandomString
            Format-SpectrePanel -Data $randomString -Title $testTitle -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
            $testConsole.Output | Should -BeLike "*$testTitle*"
        }

        It "Should create an expanded panel" {
            $testExpand = $true
            $randomString = Get-RandomString
            Format-SpectrePanel -Data $randomString -Title $testTitle -Border $testBorder -Expand:$testExpand -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
            $testConsole.Output | Should -BeLike "*$testTitle*"
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            Format-SpectrePanel -Data "This is a test panel" -Title "Test title" -Border "Rounded" -Color "Turquoise2" | Out-Null
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectrePanel" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}