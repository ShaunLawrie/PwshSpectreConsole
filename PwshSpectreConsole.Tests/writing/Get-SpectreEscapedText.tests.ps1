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
