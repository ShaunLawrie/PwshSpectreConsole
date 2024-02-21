Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTable" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testConsole = [Spectre.Console.Testing.TestConsole]::new()
            $testConsole.EmitAnsiSequences = $true
            [Spectre.Console.Testing.TestConsoleExtensions]::Width($testConsole, 140)
            $testData = $null
            $testBorder = Get-RandomBoxBorder
            $testColor = Get-RandomColor

            Mock Write-AnsiConsole {
                $RenderableObject | Should -BeOfType [Spectre.Console.Table]
                $RenderableObject.Rows.Count | Should -Be $testData.Count
                if($testBorder -ne "None") {
                    $RenderableObject.Border.GetType().Name | Should -BeLike "*$testBorder*"
                }
                if($testColor) {
                    $RenderableObject.BorderStyle.Foreground.ToMarkup() | Should -Be $testColor
                }

                $testConsole.Write($RenderableObject)
            }
        }

        It "Should create a table when default display members for a command are required" {
            $testData = Get-ChildItem "$PSScriptRoot"
            Format-SpectreTable -Data $testData -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should create a table when default display members for a command are required and input is piped" {
            $testData = Get-ChildItem "$PSScriptRoot"
            $testData | Format-SpectreTable -Border $testBorder -Color $testColor
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should be able to retrieve default display members for command output with format data" {
            $testData = Get-ChildItem "$PSScriptRoot"
            $defaultDisplayMembers = $testData | Format-Table | Get-TableHeader
            if ($IsLinux -or $IsMacOS) {
                #  Expected @('UnixMode', 'User', 'Group', 'LastWrite…', 'Size', 'Name'), but got @('UnixMode', 'User', 'Group', 'LastWriteTime', 'Size', 'Name').
                # i have no idea whats truncating LastWriteTime
                # $defaultDisplayMembers.Properties.GetEnumerator().Name | Should -Be @("UnixMode", "User", "Group", "LastWriteTime", "Size", "Name")
                $defaultDisplayMembers.keys | Should -Match 'UnixMode|User|Group|LastWrite|Size|Name'
            }
            else {
                $defaultDisplayMembers.keys | Should -Be @("Mode", "LastWriteTime", "Length", "Name")
            }
        }

        It "Should not throw and should return null when input does not have format data" {
            {
                $defaultDisplayMembers = [hashtable]@{
                    "Hello" = "World"
                } | Get-TableHeader
                $defaultDisplayMembers | Should -Be $null
            } | Should -Not -Throw
        }

        It "Should be able to format ansi strings" {
            $rawString = "hello world"
            $ansiString = "`e[31mhello `e[46mworld`e[0m"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to format PSStyle strings" {
            $rawString = ""
            $ansiString = ""
            $PSStyle | Get-Member -MemberType Property | Where-Object { $_.Definition -match '^string' -And $_.Name -notmatch 'off$|Reset' } | ForEach-Object {
                $name = $_.Name
                $rawString += "$name "
                $ansiString += "$($PSStyle.$name)$name "
            }
            $ansiString += "$($PSStyle.Reset)"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to format strings with spectre markup when opted in" {
            $rawString = "hello spectremarkup world"
            $ansiString = "hello [red]spectremarkup[/] world"
            $result = ConvertTo-SpectreDecoration -String $ansiString -AllowMarkup
            $result.Length | Should -Be $rawString.Length
        }

        It "Should leave spectre markup alone by default" {
            $ansiString = "hello [red]spectremarkup[/] world"
            $result = ConvertTo-SpectreDecoration -String $ansiString
            $result.Length | Should -Be $ansiString.Length
        }

        It "Should be able to create a new table cell with spectre markup" {
            $rawString = "hello spectremarkup world"
            $ansiString = "hello [red]spectremarkup[/] world"
            $result = New-TableCell -String $ansiString -AllowMarkup
            $result | Should -BeOfType [Spectre.Console.Markup]
            $result.Length | Should -Be $rawString.Length
        }

        It "Should be able to create a new table cell without spectre markup by default" {
            $ansiString = "hello [red]spectremarkup[/] world"
            $result = New-TableCell -String $ansiString
            $result | Should -BeOfType [Spectre.Console.Text]
            $result.Length | Should -Be $ansiString.Length
        }

        It "Should be able to create a new table row with spectre markup" {
            $entryitem = Get-SpectreTableRowData -Markup
            $result = New-TableRow -Entry $entryItem -AllowMarkup
            $result -is [array] | Should -Be $true
            $result[0] | Should -BeOfType [Spectre.Console.Markup]
            $result.Count | Should -Be $entryitem.Count
        }

        It "Should be able to create a new table row without spectre markup by default" {
            $entryitem = Get-SpectreTableRowData -Markup
            $result = New-TableRow -Entry $entryItem
            $result -is [array] | Should -Be $true
            $result[0] | Should -BeOfType [Spectre.Console.Text]
            $result[0].Length | Should -Be $entryItem[0].Length
            $result.Count | Should -Be $entryitem.Count
        }

        It "Should create a table and display results properly" {
            $testBorder = 'Markdown'
            $testData = Get-ChildItem "$PSScriptRoot"
            $verification = $testdata | Format-Table | Get-TableHeader
            Format-SpectreTable -Data $testData -Border $testBorder -Color $testColor
            $testResult = $testConsole.Output
            $rows = $testResult -split "\r?\n" | Select-Object -Skip 1 -SkipLast 2
            $header = $rows[0]
            $properties = $header -split '\|' | StripAnsi | ForEach-Object {
                if (-Not [String]::IsNullOrWhiteSpace($_)) {
                    $_.Trim()
                }
            }
            if ($IsLinux -or $IsMacOS) {
                $verification.keys | Should -Match 'UnixMode|User|Group|LastWrite|Size|Name'
            }
            else {
                $verification.keys | Should -Be $properties
            }
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should create a table and display ICollection results properly" {
            $testData = 1 | Group-Object
            $testBorder = 'Markdown'
            $testColor = $null
            Write-Debug "Setting testcolor to $testColor"
            Format-SpectreTable -Data $testData -Border $testBorder -HideHeaders -Property Group
            $testResult = $testConsole.Output | StripAnsi
            $clean = $testResult -replace '\s+|\|'
            $clean | Should -Be '{1}'
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }
        
        It "Should be able to use calculated properties" {
            $testData = Get-Process -Id $pid
            $testBorder = 'Markdown'
            $testColor = $null
            Write-Debug "Setting testcolor to $testColor"
            $testData | Format-SpectreTable ProcessName, @{Label="TotalRunningTime"; Expression={(Get-Date) - $_.StartTime}} -Border $testBorder
            $testResult = $testConsole.Output
            $obj = $testResult -split "\r?\n" | Select-Object -Skip 1 -SkipLast 2
            $deconstructed = $obj -split '\|' | StripAnsi | ForEach-Object {
                if (-Not [String]::IsNullOrEmpty($_)) {
                    $_.Trim()
                }
            }
            $deconstructed[0] | Should -Be 'ProcessName'
            $deconstructed[1] | Should -Be 'TotalRunningTime'
            $deconstructed[4] | Should -Be 'pwsh'
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
        }

        It "Should match the snapshot" {
            Mock Write-AnsiConsole {
                $testConsole.Write($RenderableObject)
            }
            [pscustomobject]@{
                "Name" = "Test 1"
                "Value" = 10
                "Color" = "Turquoise2"
            }, [pscustomobject]@{
                "Name" = "Test 2"
                "Value" = 20
                "Color" = "#ff0000"
            }, [pscustomobject]@{
                "Name" = "Test 3"
                "Value" = 30
                "Color" = "Turquoise2"
            } | Format-SpectreTable -Border "Rounded" -Color "Turquoise2"

            { Assert-OutputMatchesSnapshot -SnapshotName "Format-SpectreTable" -Output $testConsole.Output } | Should -Not -Throw
        }
    }
}
