Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Write-SpectreHost" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            $testMessage = Get-RandomString
            $testMessage | Out-Null
            Mock Write-SpectreHostInternalMarkup {
                $Message | Should -Be $testMessage
                [AnsiConsoleExtensions]::Markup($testConsole, $Message)
            }
            Mock Write-SpectreHostInternalMarkupLine {
                $Message | Should -Be $testMessage
                [AnsiConsoleExtensions]::MarkupLine($testConsole, $Message)
            }
        }

        It "writes a message" {
            Write-SpectreHost -Message $testMessage
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkupLine" -Times 1 -Exactly
            $testConsole.Output.Split("`n").Count | Should -Be 2
        }

        It "accepts pipeline input" {
            $testMessage | Write-SpectreHost
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkupLine" -Times 1 -Exactly
            $testConsole.Output.Split("`n").Count | Should -Be 2
        }

        It "handles nonewline" {
            Write-SpectreHost -Message $testMessage -NoNewline
            Assert-MockCalled -CommandName "Write-SpectreHostInternalMarkup" -Times 1 -Exactly
            $testConsole.Output.Split("`n").Count | Should -Be 1
        }

        It "Should match the snapshot" {
            $testMessage = "[#00ff00]Hello[/], [DeepSkyBlue3_1]World![/] :smiling_face_with_sunglasses: Yay!"
            Write-SpectreHost $testMessage
            $snapshotComparison = "$PSScriptRoot\..\@snapshots\Write-SpectreHost.snapshot.compare.txt"
            Set-Content -Path $snapShotComparison -Value ($testConsole.Output -replace "`r", "") -NoNewline
            $compare = Get-Content -Path $snapshotComparison -AsByteStream
            $snapshot = Get-Content -Path "$PSScriptRoot\..\@snapshots\Write-SpectreHost.snapshot.txt" -AsByteStream
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