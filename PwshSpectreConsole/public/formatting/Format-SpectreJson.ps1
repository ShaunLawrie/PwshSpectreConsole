using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Format-SpectreJson {
    <#
    .SYNOPSIS
    Formats an array of objects into a Spectre Console Json.  

    .DESCRIPTION
    This function takes an objects and converts them into syntax highlighted Json using the Spectre Console Json Library.  
    Thanks to [trackd](https://github.com/trackd) for adding this!  
    See https://spectreconsole.net/widgets/json for more information.

    .PARAMETER Data
    The array of objects to be formatted into Json.

    .PARAMETER Depth
    The maximum depth of the Json. Default is defined by the version of powershell.

    .PARAMETER NoBorder
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    The json output already has no border.
    :::

    .PARAMETER Border
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    To add a border wrap this object in a panel, use `$data | Format-SpectreJson | Format-SpectrePanel`.
    :::

    .PARAMETER Color
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    To add a border with a color use `$data | Format-SpectreJson | Format-SpectrePanel -Color "color"`.
    :::

    .PARAMETER Title
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    To add a border with a title to the json data, use `$data | Format-SpectreJson | Format-SpectrePanel -Header "title"`.
    :::

    .PARAMETER Width
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    To add a border with a width, use `$data | Format-SpectreJson | Format-SpectrePanel -Width 20`.
    :::

    .PARAMETER Height
    :::caution
    This parameter is deprecated and will be removed in the future. It takes no effect from version 2.0.
    To add a border with a width, use `$data | Format-SpectreJson | Format-SpectrePanel -Height 20`.
    :::

    .PARAMETER JsonStyle
    A hashtable of Spectre Console color names and values to style the Json output.
    e.g.
    ```
    @{
        MemberStyle    = "Yellow"
        BracesStyle    = "Red"
        BracketsStyle  = "Orange1"
        ColonStyle     = "White"
        CommaStyle     = "White"
        StringStyle    = "White"
        NumberStyle    = "Red"
        BooleanStyle   = "LightSkyBlue1"
        NullStyle      = "Gray"
    }
    ```

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to format an array of objects into a Spectre Console Json object with syntax highlighting.
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
        }
    )
    Format-SpectreJson -Data $data
    #>
    [Reflection.AssemblyMetadata("title", "Format-SpectreJson")]
    [Alias('fsj')]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [object] $Data,
        [int] $Depth,
        [switch] $NoBorder,
        [string] $Border,
        [string] $Color,
        [string] $Title,
        [int] $Width,
        [int] $Height,
        [ValidateSpectreColorTheme()]
        [ColorThemeTransformationAttribute()]
        [hashtable] $JsonStyle = @{
            MemberStyle    = $script:AccentColor
            BracesStyle    = [Spectre.Console.Color]::Cyan1
            BracketsStyle  = [Spectre.Console.Color]::Orange1
            ColonStyle     = $script:AccentColor
            CommaStyle     = $script:AccentColor
            StringStyle    = [Spectre.Console.Color]::White
            NumberStyle    = [Spectre.Console.Color]::Cyan1
            BooleanStyle   = [Spectre.Console.Color]::LightSkyBlue1
            NullStyle      = $script:DefaultValueColor
        }
    )
    begin {

        $requiredJsonStyleKeys = @('MemberStyle', 'BracesStyle', 'BracketsStyle', 'ColonStyle', 'CommaStyle', 'StringStyle', 'NumberStyle', 'BooleanStyle', 'NullStyle')
        if (($requiredJsonStyleKeys | ForEach-Object { $JsonStyle.Keys -contains $_ }) -contains $false) {
            throw "JsonStyle must contain the following keys: $($requiredJsonStyleKeys -join ', ')"
        }

        $collector = [System.Collections.Generic.List[psobject]]::new()
        $splat = @{
            WarningAction = 'Ignore'
            ErrorAction   = 'Stop'
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
                } catch {
                    Write-Debug "Failed to convert string to object, $_"
                }
            }
            if ($data -is [System.IO.FileSystemInfo]) {
                if ($data.Extension -eq '.json') {
                    Write-Debug "json file found, reading $($data.FullName)"
                    try {
                        $jsonObjects = Get-Content -Raw $data.FullName | ConvertFrom-Json -AsHashtable @splat
                        return $collector.add($jsonObjects)
                    } catch {
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
                } catch {
                    Write-Debug "Failed to convert json to object: $key, $_"
                }
            }
        }
        if ($collector.Count -eq 0) {
            return
        }
        try {
            $json = [Spectre.Console.Json.JsonText]::new(($collector | ConvertTo-Json @splat))
        } catch {
            Write-Error "Failed to convert to json, $_"
            return
        }

        $json.MemberStyle = $JsonStyle.MemberStyle
        $json.BracesStyle = $JsonStyle.BracesStyle
        $json.BracketsStyle = $JsonStyle.BracketsStyle
        $json.ColonStyle = $JsonStyle.ColonStyle
        $json.CommaStyle = $JsonStyle.CommaStyle
        $json.StringStyle = $JsonStyle.StringStyle
        $json.NumberStyle = $JsonStyle.NumberStyle
        $json.BooleanStyle = $JsonStyle.BooleanStyle
        $json.NullStyle = $JsonStyle.NullStyle

        return $json
    }
}
