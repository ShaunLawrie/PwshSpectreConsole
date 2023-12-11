using module "..\..\private\completions\Completers.psm1"

function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table.
    ![Example table](/table.png)

    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.

    .PARAMETER Data
    The array of objects to be formatted into a table.

    .PARAMETER Border
    The border style of the table. Default is "Double".

    .PARAMETER Color
    The color of the table border. Default is the accent color of the script.

    .PARAMETER Width
    The width of the table.

    .PARAMETER HideHeaders
    Hides the headers of the table.

    .PARAMETER Title
    The title of the table.

    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{Name="John"; Age=25; City="New York"},
        [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
    )
    Format-SpectreTable -Data $data
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTable")]
    [Alias('fst')]
    param (
        [Parameter(Position = 0)]
        [String[]]$Property,
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
        [ValidateSet([SpectreConsoleTableBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::BufferWidth }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int]$Width,
        [switch]$HideHeaders,
        [String]$Title
    )
    begin {
        $table = [Spectre.Console.Table]::new()
        $table.Border = [Spectre.Console.TableBorder]::$Border
        $table.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
        if ($Width) {
            $table.Width = $Width
        }
        if ($HideHeaders) {
            $table.ShowHeaders = $false
        }
        if ($Title) {
            $table.Title = [Spectre.Console.TableTitle]::new($Title, [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor)))
        }
        $collector = [System.Collections.Generic.List[psobject]]::new()
    }
    process {
        if ($data -is [array]) {
            # add array items individually to the collector
            foreach ($entry in $data) {
                $collector.add($entry)
            }
        } else {
            $collector.add($data)
        }
    }
    end {
        if ($Property) {
            $collector = $collector | Select-Object -Property $Property
            $property | ForEach-Object {
                $table.AddColumn($_) | Out-Null
            }
        }
        elseif (($standardMembers = Get-DefaultDisplayMembers $collector[0])) {
            foreach ($key in $standardMembers.keys) {
                $std = $standardMembers[$key]
                $table.AddColumn($std.Label) | Out-Null
                # if($std.width -gt 0) {
                    # width 0 is autosize.
                #     $table.Columns[$table.Columns.Count - 1].Width($std.Width) | Out-Null
                # }
            }
            $collector = $collector | Select-Object -Property $standardMembers.keys
        } else {
            foreach ($prop in $collector[0].psobject.Properties.Name) {
                if (-Not [String]::IsNullOrEmpty($prop)) {
                    $table.AddColumn($prop) | Out-Null
                }
            }
        }
        foreach ($item in $collector) {
            $row = $item.psobject.Properties | ForEach-Object {
                if ($standardMembers -and $standardMembers.Contains($_.Name)) {
                    $member = $standardMembers[$_.Name]
                    if ($member.type -eq 'ScriptBlock') {
                        $cell = & {
                            param($inside)
                            . { $_ = $args[0]; . $member.Expression } $inside
                        } $item
                        [Spectre.Console.Text]::new($cell)
                    } else {
                        [Spectre.Console.Text]::new($_.Value)
                    }
                } elseif ($null -eq $_.Value) {
                    [Spectre.Console.Text]::new(" ")
                }
                elseif (-Not [String]::IsNullOrEmpty($_.Value.ToString())) {
                    [Spectre.Console.Text]::new($_.Value.ToString())
                } else {
                    [Spectre.Console.Text]::new([String]$_.Value)
                }
            }
            $table = [Spectre.Console.TableExtensions]::AddRow($table, [Spectre.Console.Text[]]$row)
        }
        Write-AnsiConsole $table
    }
}
