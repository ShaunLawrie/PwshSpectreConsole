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

Describe "Get-SpectreEscapedText" {
    InModuleScope "PwshSpectreConsole" {

        It "formats a busted string" {
            Get-SpectreEscapedText -Text "][[][]]][[][][][" | Should -Be "]][[[[]][[]]]]]][[[[]][[]][[]][["
        }

        It "handles pipelined input" {
            "[[][]]][[][][]" | Get-SpectreEscapedText | Should -Be "[[[[]][[]]]]]][[[[]][[]][[]]"
        }

        It "leaves emoji alone, unfortunately these aren't escaped in spectre console" {
            "[[][]]][[]:zany_face:[][]" | Get-SpectreEscapedText | Should -Be "[[[[]][[]]]]]][[[[]]:zany_face:[[]][[]]"
        }
    }
}
