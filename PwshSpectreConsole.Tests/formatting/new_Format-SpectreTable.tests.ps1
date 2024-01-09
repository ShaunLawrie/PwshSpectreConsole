Remove-Module PwshSpectreConsole -Force -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot\..\..\PwshSpectreConsole\PwshSpectreConsole.psd1" -Force
Import-Module "$PSScriptRoot\..\TestHelpers.psm1" -Force

Describe "Format-SpectreTable" {
    InModuleScope "PwshSpectreConsole" {
        BeforeEach {
            $testData = $null
            $testBorder = 'Markdown'
            $testColor = Get-RandomColor
            Mock Write-AnsiConsole {
                try {
                    $writer = [System.IO.StringWriter]::new()
                    $output = [Spectre.Console.AnsiConsoleOutput]::new($writer)
                    $settings = [Spectre.Console.AnsiConsoleSettings]::new()
                    $settings.Out = $output
                    $console = [Spectre.Console.AnsiConsole]::Create($settings)
                    $console.Write($RenderableObject)
                    $writer.ToString()
                }
                finally {
                    $writer.Dispose()
                }
            }
        }
        It "Should create a table when default display members for a command are required" {
            $testData = Get-ChildItem "$PSScriptRoot"
            $verification = Get-DefaultDisplayMembers $testData
            $testResult = Format-SpectreTable -Data $testData -Border $testBorder -Color $testColor
            $rows = $testResult -split "\r?\n" | Select-Object -Skip 1 -SkipLast 2
            $header = $rows[0]
            $properties = $header -split '\|' | Get-AnsiEscapeSequence | ForEach-Object {
                if (-Not [String]::IsNullOrWhiteSpace($_.Clean)) {
                    $_.Clean -replace '\s+'
                }
            }
            $verification.Properties.keys | Should -Be $properties
            <#
            $i = 0
            foreach ($row in $rows) {
                "$i $row" | Out-String | Write-Debug -Debug
                $i++
            }
            #>
            Assert-MockCalled -CommandName "Write-AnsiConsole" -Times 1 -Exactly
            Should -InvokeVerifiable
        }
    }
}
