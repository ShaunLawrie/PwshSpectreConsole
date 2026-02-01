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

Describe "Format-SpectrePanel" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 80)
            $testTitle = Get-RandomString -MinimumLength 5 -MaximumLength 10
            $testBorder = Get-RandomBoxBorder -MustNotBeNone
            $testExpand = $false
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Panel]
                $RenderableObject.Header.Text | Should -Be $testTitle
                $RenderableObject.Expand | Should -Be $testExpand
                $RenderableObject.BorderStyle.Foreground.ToMarkup() | Should -Be $testColor
                if ($testBorder -ne "None") {
                    $RenderableObject.Border.GetType().Name | Should -BeLike "*$testBorder*"
                }

                $testConsole.Write($RenderableObject)
            }
        }

        It "Should create a panel" {
            $randomString = Get-RandomString
            $panel = Format-SpectrePanel -Data $randomString -Title $testTitle -Border $testBorder -Color $testColor
            $panel | Should -BeOfType [Spectre.Console.Panel]
            $panel | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
            $testConsole.Output | Should -BeLike "*$testTitle*"
        }

        It "Should create an expanded panel" {
            $testExpand = $true
            $randomString = Get-RandomString
            $panel = Format-SpectrePanel -Data $randomString -Title $testTitle -Border $testBorder -Expand:$testExpand -Color $testColor
            $panel | Should -BeOfType [Spectre.Console.Panel]
            $panel | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            $testConsole.Output | Should -BeLike "*$randomString*"
            $testConsole.Output | Should -BeLike "*$testTitle*"
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $panel = Format-SpectrePanel -Data "This is a test panel" -Title "Test title" -Border "Rounded" -Color "Turquoise2"
            $panel | Should -BeOfType [Spectre.Console.Panel]
            $panel | Out-SpectreHost
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectrePanel" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
