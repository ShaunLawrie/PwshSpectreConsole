using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table. Thanks to [trackd](https://github.com/trackd) and [fmotion1](https://github.com/fmotion1) for the updates to support markdown and color in the table contents.
    ![Example table](/table.png)

    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.
    It's cool.

    .PARAMETER Property
    Specifies the object properties that appear in the display and the order in which they appear.
    Type one or more property names, separated by commas, or use a hash table to display a calculated property.
    Wildcards are permitted.
    The Property parameter is optional. You can't use the Property and View parameters in the same command.
    The value of the Property parameter can be a new calculated property.
    The calculated property can be a script block or a hash table. Valid key-value pairs are:
    - Name (or Label) `<string>`
    - Expression - `<string>` or `<script block>`
    - FormatString - `<string>`
    - Width - `<int32>` - must be greater than `0`
    - Alignment - value can be `Left`, `Center`, or `Right`

    .PARAMETER Data
    The array of objects to be formatted into a table.
    Takes pipeline input.

    .PARAMETER Border
    The border style of the table. Default is "Double".

    .PARAMETER Color
    The color of the table border. Default is the accent color of the script.

    .PARAMETER HeaderColor
    The color of the table header text. Default is the DefaultTableHeaderColor.

    .PARAMETER TextColor
    The color of the table text. Default is the DefaultTableTextColor.

    .PARAMETER Width
    The width of the table.

    .PARAMETER HideHeaders
    Hides the headers of the table.

    .PARAMETER Title
    The title of the table.

    .PARAMETER AllowMarkup
    Allow Spectre markup in the table elements e.g. [green]message[/].

    .PARAMETER Wrap
    Displays text that exceeds the column width on the next line. By default, text that exceeds the column width is truncated
    Currently there is a bug with this, spectre.console/issues/1185

    .PARAMETER View
    The View parameter lets you specify an alternate format or custom view for the table.

    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{Name="John"; Age=25; City="New York"},
        [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
    )
    Format-SpectreTable -Data $data

    .EXAMPLE
    $Properties = @(
        # foreground + background
        @{'Name'='FileName'; Expression={ "[orange1 on blue]" + $_.Name + "[/]" }},
        # foreground
        @{'Name'='Last Updated'; Expression={ "[DeepSkyBlue3_1]" + $_.LastWriteTime.ToString() + "[/]" }},
        # background
        @{'Name'='Drive'; Expression={ "[default on orange1]" + (Split-Path $_.Fullname -Qualifier) + "[/]" }}
    )
    Get-ChildItem | Format-SpectreTable -Property $Properties -AllowMarkup

    .EXAMPLE
    1..10 | Format-SpectreTable -Title Numbers
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTable")]
    [cmdletbinding(DefaultParameterSetName = '__AllParameterSets')]
    [Alias('fst')]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [Alias('InputObject')]
        [object] $Data,
        [Parameter(Position = 0, ParameterSetName = 'Property')]
        [object[]] $Property,
        [Switch] $Wrap,
        [Parameter(ParameterSetName = 'View')]
        [String] $View,
        [ValidateSet([SpectreConsoleTableBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $HeaderColor = $script:DefaultTableHeaderColor,
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $TextColor = $script:DefaultTableTextColor,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int] $Width,
        [switch] $HideHeaders,
        [String] $Title,
        [switch] $AllowMarkup
    )
    begin {
        Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
        $tableoptions = @{}
        $rowoptions = @{}
        $FormatTableParams = @{}
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $table = [Table]::new()
        $table.Border = [TableBorder]::$Border
        $table.BorderStyle = [Style]::new($Color)
        switch ($PSBoundParameters.Keys) {
            'Width' { $table.Width = $Width }
            'HideHeaders' { $table.ShowHeaders = $false }
            'Title' { $tableoptions.Title = $Title }
            'AllowMarkup' { $rowoptions.AllowMarkup = $true }
            'Wrap' { $tableoptions.Wrap = $true ; $FormatTableParams.Wrap = $true }
            'View' { $FormatTableParams.View = $View }
            'Property' { $FormatTableParams.Property = $Property }
        }
    }
    process {
        foreach ($entry in $data) {
            if ($entry -is [hashtable]) {
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
        if ($FormatTableParams.Keys.Count -gt 0) {
            Write-Debug "Using Format-Table with parameters: $($FormatTableParams.Keys -join ', ')"
            $collector = $collector | Format-Table @FormatTableParams
        } else {
            $collector = $collector | Format-Table
        }
        if (-Not $collector.shapeInfo) {
            # scalar array, no header
            $rowoptions.scalar = $tableoptions.scalar = $true
            $table = Add-TableColumns -Table $table @tableoptions -Color $HeaderColor
        } else {
            # grab the FormatStartData
            $Headers = Get-TableHeader $collector[0]
            if ($Headers) {
                $table = Add-TableColumns -Table $table -formatData $Headers -Color $HeaderColor
            } else {
                return
            }
        }
        foreach ($item in $collector.FormatEntryInfo) {
            if ($rowoptions.scalar) {
                $row = New-TableRow -Entry $item.Text -Color $TextColor @rowoptions
            } else {
                if ($null -eq $item.FormatPropertyFieldList.propertyValue) {
                    continue
                }
                $row = New-TableRow -Entry $item.FormatPropertyFieldList.propertyValue -Color $TextColor @rowoptions
            }
            if ($AllowMarkup) {
                $table = [TableExtensions]::AddRow($table, [Markup[]]$row)
            } else {
                $table = [TableExtensions]::AddRow($table, [Text[]]$row)
            }
        }
        if ($Title -And -Not $rowoptions.scalar) {
            $table.Title = [TableTitle]::new($Title, [Style]::new($Color))
        }
        Write-AnsiConsole $table
    }
}
