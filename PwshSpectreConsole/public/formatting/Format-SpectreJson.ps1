using module "..\..\private\completions\Completers.psm1"

function Format-SpectreJson {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console Json.

    .DESCRIPTION
    This function takes an array of objects and converts them into Json using the Spectre Console Json Library.

    .PARAMETER Data
    The array of objects to be formatted into Json.

    .PARAMETER Border
    The border style of the Json. Default is "Rounded".

    .PARAMETER Color
    The color of the Json border. Default is the accent color of the script.

    .PARAMETER Title
    The title of the Json.

    .EXAMPLE
    # This example formats an array of objects into a table with a double border and the accent color of the script.
    $data = @(
        [pscustomobject]@{
            Name = "John"
            Age = 25
            City = "New York"
            IsEmployed = $true
            Salary = 10
            Hobbies = @("Reading", "Swimming")
            Address = @{
                Street = "123 Main St"
                ZipCode = $null
            }
        },
        [pscustomobject]@{
            Name = "Jane"
            Age = 30
            City = "Los Angeles"
            IsEmployed = $false
            Salary = $null
            Hobbies = @("Painting", "Hiking")
            Address = @{
                Street = "456 Elm St"
                ZipCode = "90001"
            }
        }
    )
    Format-SpectreJson -Data $data -Title "Employee Data" -Border "Rounded" -Color "Green"
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreJson")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [array] $Data,
        [string] $Title,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup()
    )
    begin {
        $collector = [System.Collections.Generic.List[psobject]]::new()
    }
    process {
        $collector.add($data)
    }
    end {
        $jsonText = [Spectre.Console.Json.JsonText]::new(($collector | ConvertTo-Json -WarningAction Ignore))
        $jsonText.BracesStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Red)
        $jsonText.BracketsStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Green)
        $jsonText.ColonStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Blue)
        $jsonText.CommaStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::CadetBlue)
        $jsonText.StringStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Yellow)
        $jsonText.NumberStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Cyan2)
        $jsonText.BooleanStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Teal)
        $jsonText.NullStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Plum1)
        $json = [Spectre.Console.Panel]::new($jsonText)
        $json.Border = [Spectre.Console.BoxBorder]::$Border
        $json.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
        if ($Title) {
            $json.Header = [Spectre.Console.PanelHeader]::new($Title)
        }
        Write-AnsiConsole $json
    }
}
