Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTable" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testData = $null
            $testBorder = Get-RandomBoxBorder
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole -Verifiable -ParameterFilter {
                $RenderableObject -is [Spectre.Console.Table] `
                -and ($testBorder -eq "None" -or $RenderableObject.Border.GetType().Name -like "*$testBorder*") `
                -and $RenderableObject.BorderStyle.Foreground.ToMarkup() -eq $testColor `
                -and $RenderableObject.Rows.Count -eq $testData.Count
            }
        }
        
        It "Should create a table when default display members for a command are required" {
            $testData = Get-ChildItem "$PSScriptRoot"
            Format-SpectreTable -Data $testData -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "Should create a table when default display members for a command are required and input is piped" {
            $testData = Get-ChildItem "$PSScriptRoot"
            $testData | Format-SpectreTable -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }

        It "Should be able to retrieve default display members for command output with format data" {
            $testData = Get-ChildItem "$PSScriptRoot"
            $defaultDisplayMembers = $testData | Get-DefaultDisplayMembers
            if($IsLinux -or $IsMacOS) {
                $defaultDisplayMembers.Properties.GetEnumerator().Name | Should -Be @("UnixMode", "User", "Group", "LastWriteTime", "Size", "Name")
            } else {
                $defaultDisplayMembers.Properties.GetEnumerator().Name | Should -Be @("Mode", "LastWriteTime", "Length", "Name")
            }
        }

        It "Should not throw and should return null when input does not have format data" {
            {
                $defaultDisplayMembers = [hashtable]@{
                    "Hello" = "World"
                } | Get-DefaultDisplayMembers
                $defaultDisplayMembers | Should -Be $null
            } | Should -Not -Throw
        }

        It "Should be able to format ansi strings" {
            $rawString =  "hello world"
            $ansiString =  "`e[31mhello `e[46mworld`e[0m"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to format PSStyle strings" {
            $rawString = ""
            $ansiString = ""
            $PSStyle | Get-Member -MemberType Properties | ForEach-Object {
                $name = $_.Name
                $rawString += "$name "
                $ansiString += "$($PSStyle.$name)$name "
            }
            $ansiString += "$($PSStyle.Reset)"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to format strings with spectre markup when opted in" {
            $rawString =  "hello spectremarkup world"
            $ansiString =  "hello [red]spectremarkup[/] world"
            $result = ConvertTo-SpectreDecoration -String $ansiString -AllowMarkup
            $result.Length | Should -Be $rawString.Length
        }

        It "Should leave spectre markup alone by default" {
            $ansiString =  "hello [red]spectremarkup[/] world"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $ansiString.Length
        }

        It "Should be able to create a new table cell with spectre markup" {
            $rawString =  "hello spectremarkup world"
            $ansiString =  "hello [red]spectremarkup[/] world"
            $result = New-TableCell -String $ansiString -AllowMarkup
            $result | Should -BeOfType [Spectre.Console.Markup]
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to create a new table cell without spectre markup by default" {
            $ansiString =  "hello [red]spectremarkup[/] world"
            $result = New-TableCell -String $ansiString
            $result | Should -BeOfType [Spectre.Console.Text]
            $result.Length | Should -Be $ansiString.Length
        }

        It "Should be able to create a new table row with spectre markup" {
            $rawString =  "Markup"
            $entryItem = [pscustomobject]@{
                "Markup" = "[red]Markup[/]"
                "Also" = "Hello"
            }
            $result = New-TableRow -Entry $entryItem -AllowMarkup
            $result -is [array] | Should -Be $true
            $result[0] | Should -BeOfType [Spectre.Console.Markup]
            $result[0].Length | Should -Be $rawString.Length
            $result.Count | Should -Be ($entryItem.PSObject.Properties | Measure-Object).Count
        }

        It "Should be able to create a new table row without spectre markup by default" {
            $entryItem = [pscustomobject]@{
                "Markup" = "[red]Markup[/]"
                "Also" = "Hello"
            }
            $result = New-TableRow -Entry $entryItem
            $result -is [array] | Should -Be $true
            $result[0] | Should -BeOfType [Spectre.Console.Text]
            $result[0].Length | Should -Be $entryItem.Markup.Length
            $result.Count | Should -Be ($entryItem.PSObject.Properties | Measure-Object).Count
        }
    }
}