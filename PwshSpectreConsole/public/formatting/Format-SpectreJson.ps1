using module "..\..\private\completions\Completers.psm1"

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
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
        [int] $Depth,
        [string] $Title,
        [switch] $NoBorder,
        [ValidateSet([SpectreConsoleBoxBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Rounded",
        [ValidateSpectreColor()]
        [ArgumentCompletionsSpectreColors()]
        [string] $Color = $script:AccentColor.ToMarkup(),
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostWidth) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console width.")]
        [int] $Width,
        [ValidateScript({ $_ -gt 0 -and $_ -le (Get-HostHeight) }, ErrorMessage = "Value '{0}' is invalid. Cannot be negative or exceed console height.")]
        [int] $Height,
        [switch] $Expand,
        [switch] $ShowSourceFile
    )
    begin {
        $collector = [System.Collections.Generic.List[psobject]]::new()
        $splat = @{
            WarningAction = "Ignore"
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
                    $jsonObjects = $data | ConvertFrom-Json -AsHashtable -ErrorAction Stop
                    return $collector.add($jsonObjects)
                }
                catch {
                    # its probably a string and not json, will be added at the end to collector.
                    Write-Debug "Failed to convert string to object, $_"
                }
            }
            if ($data -is [System.IO.FileSystemInfo]) {
                if ($data.Extension -eq '.json') {
                    Write-Debug "json file found, reading $($data.FullName)"
                    $jsonObjects = Get-Content -Raw $data | ConvertFrom-Json -AsHashtable
                    # if ($ShowSourceFile.IsPresent) {
                    # this breaks for strings that cant be converted to a hashtable
                    #     $jsonObjects.add('_sourcefile',$($data.FullName))
                    # }
                    return $collector.add($jsonObjects)
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
                $jsonObject = $ht[$key].ToString() | ConvertFrom-Json -ErrorAction stop -AsHashtable
                # if ($ShowSourceFile.IsPresent) {
                #     # $jsonObject.'_sourcefile' = $key
                #     $jsonObject.add('_sourcefile',$key)
                # }
                $collector.add($jsonObject)
            }
        }
        if ($collector.Count -eq 0) {
            return
        }
        $json = [Spectre.Console.Json.JsonText]::new(($collector | ConvertTo-Json @splat))
        $json.BracesStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Red)
        $json.BracketsStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Green)
        $json.ColonStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Blue)
        $json.CommaStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::CadetBlue)
        $json.StringStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Yellow)
        $json.NumberStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Cyan2)
        $json.BooleanStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Teal)
        $json.NullStyle = [Spectre.Console.Style]::new([Spectre.Console.Color]::Plum1)

        if ($NoBorder) {
            Write-AnsiConsole $json
            return
        }

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
        if ($Expand) {
            $panel.Expand = $Expand
        }
        Write-AnsiConsole $panel
    }
}
