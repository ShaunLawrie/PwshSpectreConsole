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
        $tableoptions = @{}
        $rowoptions = @{}
        if ($Width) {
            $table.Width = $Width
        }
        if ($HideHeaders) {
            $table.ShowHeaders = $false
        }
        if ($Title) {
            $table.Title = [TableTitle]::new($Title, [Style]::new(($Color | Convert-ToSpectreColor)))
            $tableoptions.Title = $Title # used if scalar type.
        }
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $strip = '\x1B\[[0-?]*[ -/]*[@-~]'
        if ($AllowMarkup) {
            $rowoptions.AllowMarkup = $true
        }
    }
    process {
        foreach ($entry in $data) {
            if($entry -is [hashtable]) {
                $collector.add([pscustomobject]$entry)
            } else {
                $collector.add($entry)
            }
        }
    }
    end {
        if ($collector.count -eq 0) {
            return
        }
        if ($Property) {
            $collector = $collector | Select-Object -Property $Property
            $tableoptions.Property = $Property
        }
        elseif ($standardMembers = Get-DefaultDisplayMembers $collector[0]) {
            $collector = $collector | Select-Object $standardMembers.Format
            $tableoptions.FormatData = $standardMembers.Properties
            $rowoptions.FormatFound = $true
        }
        $table = Add-TableColumns -Table $table -Object $collector[0] @tableoptions
        foreach ($item in $collector) {
            $row = New-TableRow -Entry $item @rowoptions
            if($AllowMarkup) {
                $table = [TableExtensions]::AddRow($table, [Markup[]]$row)
            } else {
                $table = [TableExtensions]::AddRow($table, [Text[]]$row)
            }
        }
        Write-AnsiConsole $table
    }
}
