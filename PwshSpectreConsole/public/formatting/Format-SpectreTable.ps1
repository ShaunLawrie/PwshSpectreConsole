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
        [object[]]$Property,
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
        [ValidateSet([SpectreConsoleTableBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
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
            # used if scalar type as 'Value'
            $tableoptions.Title = $Title
        }
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $strip = '\x1B\[[0-?]*[ -/]*[@-~]'
        if ($AllowMarkup) {
            $rowoptions.AllowMarkup = $true
        }
    }
    process {
        foreach ($entry in $data) {
            if ($entry -is [hashtable]) {
                $collector.add([pscustomobject]$entry)
            }
            else {
                $collector.add($entry)
            }
        }
    }
    end {
        if ($collector.count -eq 0) {
            return
        }
        if ($Property) {
            $collector = $collector | Format-Table -Property $Property
        }
        else {
            $collector = $collector | Format-Table
        }
        if ($collector[0].PSTypeNames[0] -eq 'Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData') {
            # scalar array, no header
            $rowoptions.scalar = $tableoptions.scalar = $true
            $table = Add-TableColumns -Table $table @tableoptions
        }
        else {
            # grab the FormatStartData
            $Headers = Get-TableHeader $collector[0]
            $table = Add-TableColumns -Table $table -formatData $Headers
            # Remove the FormatStartData and FormatEndData [0] and [-1], Remove GroupStartData and GroupEndData [1] and [-2]
            # collector should only contain FormatEntryData
            # upgrade to 7.4 already..
            # $collector = $collector | Select-Object -Skip 2 -SkipLast 2
            $collector = $collector | Select-Object -Skip 2 | Select-Object -SkipLast 2
        }
        foreach ($item in $collector) {
            if ($rowoptions.scalar) {
                $row = New-TableRow -Entry $item.FormatEntryInfo.Text @rowoptions
            }
            else {
                $row = New-TableRow -Entry $item.FormatEntryInfo.FormatPropertyFieldList @rowoptions
            }
            if ($AllowMarkup) {
                $table = [TableExtensions]::AddRow($table, [Markup[]]$row)
            }
            else {
                $table = [TableExtensions]::AddRow($table, [Text[]]$row)
            }
        }
        if ($Title -And $scalarDetected -eq $false) {
            $table.Title = [TableTitle]::new($Title, [Style]::new(($Color | Convert-ToSpectreColor)))
        }
        Write-AnsiConsole $table
    }
}
