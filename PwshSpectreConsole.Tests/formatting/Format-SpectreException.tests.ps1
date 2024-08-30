Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreException" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format an error record" {
            try {
                Get-ChildItem -BadParam -ErrorAction Stop
            } catch {
                $_ | Should -BeOfType [System.Management.Automation.ErrorRecord]
                $renderable = $_ | Format-SpectreException -ExceptionFormat ShortenEverything
            }
            $renderable | Should -BeOfType [Spectre.Console.Rows]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreException" -Output $testConsole.Output } | Should -Not -Throw
        }

        It "Should format an exception" {
            $testException = [System.Exception]::new("Test exception")
            $renderable = Format-SpectreException -Exception $testException -ExceptionFormat ShortenEverything
            $renderable | Should -BeOfType [Spectre.Console.Rows]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should format an exception with custom styles" {
            try {
                Get-ChildItem -BadParam -ErrorAction Stop
            } catch {
                $_ | Should -BeOfType [System.Management.Automation.ErrorRecord]
                $renderable = Format-SpectreException -Exception $_ -ExceptionFormat ShortenEverything -ExceptionStyle @{
                    Message        = "Red"
                    Exception      = "White"
                    Method         = [Spectre.Console.Color]::Pink3
                    ParameterType  = "Grey69"
                    ParameterName  = "Silver"
                    Parenthesis    = "#ff0000"
                    Path           = [Spectre.Console.Color]::Pink3
                    LineNumber     = "Blue"
                    Dimmed         = "Grey"
                    NonEmphasized  = "Red"
                }
            }
            
            $renderable | Should -BeOfType [Spectre.Console.Rows]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreException.CustomStyles" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}