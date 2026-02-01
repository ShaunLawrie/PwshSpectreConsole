BeforeAll {
    if (-Not (Get-Module PwshSpectreConsole)) {
        if ($env:RunMergedPsm1Tests) {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'output' 'PwshSpectreConsole.psd1')
        }
        else {
            $ModulePath = Resolve-Path (Join-Path $PSScriptRoot '..' '..' 'PwshSpectreConsole' 'PwshSpectreConsole.psd1')
        }
        Write-Host "Importing PwshSpectreConsole module from $ModulePath"
        Import-Module $ModulePath -ErrorAction Stop
    }
    if (-Not (Get-Module TestHelpers)) {
        $TestHelpersPath = Resolve-Path (Join-Path $PSScriptRoot '..' 'TestHelpers.psm1')
        Import-Module $TestHelpersPath -ErrorAction Stop
    }
}

Describe "Format-SpectreColumns" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Rendering.Renderable]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format an array of strings into columns" {
            $renderable = Format-SpectreColumns -Data @("lorem", "ipsum", "dolor", "sit", "amet", "consectetur", "adipiscing", "elit,", "sed", "do", "eiusmod",
                "tempor", "incididunt", "ut", "labore", "et", "dolore", "magna", "aliqua.", "Ut", "enim", "ad", "minim",
                "veniam,", "quis", "nostrud", "exercitation", "ullamco", "laboris", "nisi", "ut", "aliquip", "ex", "ea",
                "commodo", "consequat", "duis", "aute", "irure", "dolor", "in", "reprehenderit", "in", "voluptate", "velit",
                "esse", "cillum", "dolore", "eu", "fugiat", "nulla", "pariatur", "excepteur", "sint", "occaecat",
                "cupidatat", "non", "proident", "sunt", "in", "culpa")
            $renderable | Should -BeOfType [Spectre.Console.Columns]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should expand items to fill the available space" {
            $renderable = @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel } | Format-SpectreColumns -Expand
            $renderable | Should -BeOfType [Spectre.Console.Columns]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreColumns.Expanded" -Output $testConsole.Output } | Should -Not -Throw
        }

        It "Should allow padding to be set" {
            $renderable = @("left", "middle", "right") | Foreach-Object { $_ | Format-SpectrePanel } | Format-SpectreColumns -Padding 4
            $renderable | Should -BeOfType [Spectre.Console.Columns]
            $renderable | Out-SpectreHost
            $renderable.Padding.Top | Should -Be 4
            $renderable.Padding.Right | Should -Be 4
            $renderable.Padding.Bottom | Should -Be 4
            $renderable.Padding.Left | Should -Be 4
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }
    }
}
