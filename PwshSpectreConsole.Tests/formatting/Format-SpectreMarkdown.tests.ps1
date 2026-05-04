Describe "Format-SpectreMarkdown" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 80)
        }

        It "Should render basic markdown" {
            $markdown = @'
# Heading 1

**Bold text** and *italic text*.
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables.Count | Should -BeGreaterThan 0
            $renderables[0] | Should -BeOfType [Spectre.Console.Rule]
            $renderables[1] | Should -BeOfType [Spectre.Console.Markup]
        }

        It "Should render a table" {
            $markdown = @'
| Header 1 | Header 2 |
| --- | --- |
| Cell 1 | Cell 2 |
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Table]
        }

        It "Should render a fenced code block" {
            $markdown = @'
```pwsh
Get-Process
```
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Panel]
            $renderables[0].Header.Text | Should -Be "[dim]pwsh[/]"
        }

        It "Should wrap in a panel when Title is provided" {
            $markdown = "Hello World"
            $renderables = Format-SpectreMarkdown -Markdown $markdown -Title "My Title" -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Panel]
            $renderables[0].Header.Text | Should -Be "[bold]My Title[/]"
        }

        It "Should render nested lists using tree guide characters" {
            $markdown = @'
- Item 1
  - Sub A
    - Deep
  - Sub B
- Item 2
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Panel]
            $testConsole.Write($renderables[0])
            # Tree widget produces guide characters for hierarchy
            $testConsole.Output | Should -Match '├──|└──'
        }

        It "Should render an ordered list using tree guide characters" {
            $markdown = @'
1. First
2. Second
   1. Nested
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Panel]
            $testConsole.Write($renderables[0])
            $testConsole.Output | Should -Match '├──|└──'
        }

        It "Should render nested blockquotes with multiple Heavy borders" {
            $markdown = @'
> Outer quote
>> Inner quote
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Panel]
            $testConsole.Write($renderables[0])
            # Both the outer and inner blockquote produce a Heavy top border (┏)
            ($testConsole.Output | Select-String '┏' -AllMatches).Matches.Count | Should -BeGreaterOrEqual 2
        }

        It "Should render table cells with inline Markdown formatting" {
            $markdown = @'
| Name | Status |
| --- | --- |
| **Bold** | `code` |
'@
            $renderables = $markdown | Format-SpectreMarkdown -PassThru
            $renderables[0] | Should -BeOfType [Spectre.Console.Table]
            $testConsole.Write($renderables[0])
            # Bold cell renders ANSI bold sequence
            $testConsole.Output | Should -Match '\[1m'
        }

        It "Should match the snapshot" {
            $markdown = @'
# PwshSpectreConsole Markdown

This is a **test** of the markdown rendering.

* Item 1
* Item 2

> This is a quote

```pwsh
Write-Host "Hello"
```
'@
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            $markdown | Format-SpectreMarkdown
            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreMarkdown" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
