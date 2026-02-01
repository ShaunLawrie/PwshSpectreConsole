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

Describe "Format-SpectreTextPath" {
    InModuleScope "PwshSpectreConsole" {

        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.TextPath]
                $testConsole.Write($RenderableObject)
            }
        }

        It "Should format a path" {
            $renderable = Format-SpectreTextPath -Path "C:\Windows\System32\cmd.exe"
            $renderable | Should -BeOfType [Spectre.Console.TextPath]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTextPath" -Output $testConsole.Output } | Should -Not -Throw
        }

        It "Should format with a custom format" {
            $renderable = Format-SpectreTextPath -Path "C:\Windows\System32\cmd.exe" -PathStyle @{
                RootColor      = [Spectre.Console.Color]::Cyan2
                SeparatorColor = [Spectre.Console.Color]::Aqua
                StemColor      = [Spectre.Console.Color]::Orange1
                LeafColor      = [Spectre.Console.Color]::HotPink
            }
            $renderable | Should -BeOfType [Spectre.Console.TextPath]
            $renderable | Out-SpectreHost
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTextPathCustom" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
