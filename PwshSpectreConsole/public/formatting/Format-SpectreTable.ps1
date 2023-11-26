using module "..\..\private\completions\Completers.psm1"

function Format-SpectreTable {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console table.
    
    .DESCRIPTION
    This function takes an array of objects and formats them into a table using the Spectre Console library. The table can be customized with a border style and color.
    
    .PARAMETER Data
    The array of objects to be formatted into a table.
    
    .PARAMETER Border
    The border style of the table. Default is "Double".
    
    .PARAMETER Color
    The color of the table border. Default is the accent color of the script.
    
    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{Name="John"; Age=25; City="New York"},
        [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
    )
    Format-SpectreTable -Data $data
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreTable")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [ValidateSet([SpectreConsoleTableBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup()
    )
    begin {
        $table = [Spectre.Console.Table]::new()
        $table.Border = [Spectre.Console.TableBorder]::$Border
        $table.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
        $headerProcessed = $false
    }
    process {
        if(!$headerProcessed) {
            $Data[0].psobject.Properties.Name | Foreach-Object {
                $table.AddColumn($_) | Out-Null
            }
            
            $headerProcessed = $true
        }
        $Data | Foreach-Object {
            $row = @()
            $_.psobject.Properties | ForEach-Object {
                $cell = $_.Value
                if ($null -eq $cell) {
                    $row += [Spectre.Console.Text]::new("")
                }
                else {
                    $row += [Spectre.Console.Text]::new($cell.ToString())
                }
            }
            $table = [Spectre.Console.TableExtensions]::AddRow($table, [Spectre.Console.Text[]]$row)
        }
    }
    end {
        Write-AnsiConsole $table
    }
}