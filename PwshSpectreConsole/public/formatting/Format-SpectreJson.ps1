using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

function Format-SpectreJson {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console Json.
    Thanks to [trackd](https://github.com/trackd) for adding this.
    ![Spectre json example](/json.png)

    .DESCRIPTION
    This function takes an array of objects and converts them into Json using the Spectre Console Json Library.

    .PARAMETER Data
    The array of objects to be formatted into Json.

    .PARAMETER Depth
    The maximum depth of the Json. Default is defined by the version of powershell.

    .PARAMETER NoBorder
    If specified, the Json will not be surrounded by a border.

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
    [Alias('fsj')]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
        [int] $Depth,
        [string] $Title,
        [switch] $NoBorder,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Color] $Color = $script:AccentColor,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int] $Width,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostHeight) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console height.")]
        [int] $Height,
        [switch] $Expand
    )
    begin {
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $splat = @{
            WarningAction = 'Ignore'
            ErrorAction  = 'Stop'
        }
        if ($Depth) {
            $splat.Depth = $Depth
        }
        $ht = [ordered]@{}
    }
    process {
        if ($MyInvocation.ExpectingInput) {
            if ($data -is [string]) {
                if ($data.pschildname) {
                    if (-Not $ht.contains($data.pschildname)) {
                        $ht[$data.pschildname] = [System.Text.StringBuilder]::new()
                    }
                    return [void]$ht[$data.pschildname].AppendLine($data)
                }
                # assume we get the entire json in one go a string (e.g -Raw or invoke-webrequest)
                try {
                    $jsonObjects = $data | Out-String | ConvertFrom-Json -AsHashtable @splat
                    return $collector.add($jsonObjects)
                }
                catch {
                    Write-Debug "Failed to convert string to object, $_"
                }
            }
            if ($data -is [System.IO.FileSystemInfo]) {
                if ($data.Extension -eq '.json') {
                    Write-Debug "json file found, reading $($data.FullName)"
                    try {
                        $jsonObjects = Get-Content -Raw $data.FullName | ConvertFrom-Json -AsHashtable @splat
                        return $collector.add($jsonObjects)
                    }
                    catch {
                        Write-Debug "Failed to convert json to object, $_"
                    }
                }
                return $collector.add(
                    [pscustomobject]@{
                        Name     = $data.Name
                        FullName = $data.FullName
                        Type     = $data.GetType().Name.TrimEnd('Info')
                    })
            }
            Write-Debug "adding item from pipeline"
            return $collector.add($data)
        }
        foreach ($item in $data) {
            Write-Debug "adding item from input"
            $collector.add($item)
        }
    }
    end {
        if ($ht.keys.count -gt 0) {
            foreach ($key in $ht.Keys) {
                Write-Debug "converting json stream to object, $key"
                try {
                    $jsonObject = $ht[$key].ToString() | Out-String | ConvertFrom-Json -AsHashtable @splat
                    $collector.add($jsonObject)
                    continue
                }
                catch {
                    Write-Debug "Failed to convert json to object: $key, $_"
                }
            }
        }
        if ($collector.Count -eq 0) {
            return
        }
        try {
            $json = [Json.JsonText]::new(($collector | ConvertTo-Json @splat))
        }
        catch {
            Write-Error "Failed to convert to json, $_"
            return
        }
        $json.BracesStyle = [Style]::new([Color]::Red)
        $json.BracketsStyle = [Style]::new([Color]::Green)
        $json.ColonStyle = [Style]::new([Color]::Blue)
        $json.CommaStyle = [Style]::new([Color]::CadetBlue)
        $json.StringStyle = [Style]::new([Color]::Yellow)
        $json.NumberStyle = [Style]::new([Color]::Cyan2)
        $json.BooleanStyle = [Style]::new([Color]::Teal)
        $json.NullStyle = [Style]::new([Color]::Plum1)

        if ($NoBorder) {
            Write-AnsiConsole $json
            return
        }

        $panel = [Panel]::new($json)
        $panel.Border = [BoxBorder]::$Border
        $panel.BorderStyle = [Style]::new($Color)
        if ($Title) {
            $panel.Header = [PanelHeader]::new($Title)
        }
        if ($width) {
            $panel.Width = $Width
        }
        if ($height) {
            $panel.Height = $Height
        }
        if ($Expand) {
            $panel.Expand = $Expand
        }
        Write-AnsiConsole $panel
    }
}
