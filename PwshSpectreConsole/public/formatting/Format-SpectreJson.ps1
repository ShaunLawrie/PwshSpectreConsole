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

    .PARAMETER Width
    The width of the Json panel.

    .PARAMETER Height
    The height of the Json panel.

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
        [object] $Data,
        [string] $Title,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::BufferWidth }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int] $Width,
        [ValidateScript({ $_ -gt 0 -and $_ -le [console]::WindowHeight }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console height.")]
        [int] $Height
    )
    begin {
        $collector = [System.Collections.Generic.List[psobject]]::new()
    }
    process {
        $collector.add($data)
    }
    end {
        $json = [Spectre.Console.Json.JsonText]::new(($collector | ConvertTo-Json -WarningAction Ignore))
        $json.BracesStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Red)
        $json.BracketsStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Green)
        $json.ColonStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Blue)
        $json.CommaStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::CadetBlue)
        $json.StringStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Yellow)
        $json.NumberStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Cyan2)
        $json.BooleanStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Teal)
        $json.NullStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Plum1)
        $panel = [Spectre.Console.Panel]::new($json)
        $panel.Border = [Spectre.Console.BoxBorder]::$Border
        $panel.BorderStyle = [Spectre.Console.Style]::new(($Color | Convert-ToSpectreColor))
        if ($Title) {
            $panel.Header = [Spectre.Console.PanelHeader]::new($Title)
        }
        if ($width) {
            $panel.Width = $Width
        }
        if ($height) {
            $panel.Height = $Height
        }
        Write-AnsiConsole $panel
    }
}
