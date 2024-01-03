using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table. Thanks to [trackd](https://github.com/trackd) and [fmotion1](https://github.com/fmotion1) for the updates to support markdown and color in the table contents.
    ![Example table](/table.png)

    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.

    .PARAMETER Property
    The list of properties to select for the table from the input data.

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

    .PARAMETER AllowMarkup
    Allow Spectre markup in the table elements e.g. [green]message[/].

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
        [String]$Title,
        [switch]$AllowMarkup
    )
    begin {
        $table = [Table]::new()
        $table.Border = [TableBorder]::$Border
        $table.BorderStyle = [Style]::new(($Color | Convert-ToSpectreColor))
        if ($Width) {
            $table.Width = $Width
        }
        if ($HideHeaders) {
            $table.ShowHeaders = $false
        }
        if ($Title) {
            $table.Title = [TableTitle]::new($Title, [Style]::new(($Color | Convert-ToSpectreColor)))
        }
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $strip = '\x1B\[[0-?]*[ -/]*[@-~]'
        # [Spectre.Console.AnsiConsole]::Profile.Capabilities.Ansi = false
    }
    process {
        foreach ($entry in $data) {
            $collector.add($entry)
        }
    }
    end {
        if ($collector.count -eq 0) {
            return
        }
        if ($Property) {
            $collector = $collector | Select-Object -Property $Property
            $property | ForEach-Object {
                $table.AddColumn($_) | Out-Null
            }
        }
        elseif (($collector[-1].PSTypeNames[0] -notmatch 'PSCustomObject') -And ($standardMembers = Get-DefaultDisplayMembers $collector[-1])) {
            foreach ($key in $standardMembers.Properties.keys) {
                $lookup = $standardMembers.Properties[$key]
                $table.AddColumn($lookup.Label) | Out-Null
                # $table.Columns[-1].Padding = [Spectre.Console.Padding]::new(0, 0, 0, 0)
                if ($lookup.width -gt 0) {
                    # width 0 is autosize, select the last entry in the column list
                    # Write-Debug "Label: $($lookup.Label) width to $($lookup.Width)"
                    $table.Columns[-1].Width = $lookup.Width
                }
                if ($lookup.Alignment -ne 'undefined') {
                    $table.Columns[-1].Alignment = [Justify]::$lookup.Alignment
                }
            }
            # this formats the values according to the formatdata so we dont have to do it in the loop.
            $collector = $collector | Select-Object $standardMembers.Format
        }
        else {
            Write-Debug 'no formatting found and no properties selected, enumerating psobject.properties.name'
            foreach ($prop in $collector[0].psobject.Properties.Name) {
                if (-Not [String]::IsNullOrEmpty($prop)) {
                    $table.AddColumn($prop) | Out-Null
                }
            }
        }
        foreach ($item in $collector) {
            $row = foreach ($cell in $item.psobject.Properties) {
                if ($standardMembers -And $cell.value -match $strip) {
                    # we are dealing with an object that has VT codes and a formatdata entry.
                    # this returns a spectre.console.text/markup object with the VT codes applied.
                    ConvertTo-SpectreDecoration $cell.value -AllowMarkup:$AllowMarkup
                    continue
                }
                if ($null -eq $cell.Value) {
                    if($AllowMarkup) {
                        [Markup]::new(" ")
                    } else {
                        [Text]::new(" ")
                    }
                }
                elseif (-Not [String]::IsNullOrEmpty($cell.Value.ToString())) {
                    if($AllowMarkup) {
                        [Markup]::new($cell.Value.ToString())
                    } else {
                        [Text]::new($cell.Value.ToString())
                    }
                }
                else {
                    if($AllowMarkup) {
                        [Markup]::new([String]$cell.Value)
                    } else {
                        [Text]::new([String]$cell.Value)
                    }
                }
            }
            if($AllowMarkup) {
                $table = [TableExtensions]::AddRow($table, [Markup[]]$row)
            } else {
                $table = [TableExtensions]::AddRow($table, [Text[]]$row)
            }
        }
        Write-AnsiConsole $table
    }
}
