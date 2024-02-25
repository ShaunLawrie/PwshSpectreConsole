using namespace Spectre.Console

function Get-RandomColor {
    $type = 1 # Get-Random -Minimum 0 -Maximum 2
    switch ($type) {
        0 {
            $colors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
            return $colors[$(Get-Random -Minimum 0 -Maximum $colors.Count)]
        }
        1 {
            $hex = @()
            for ($i = 0; $i -lt 3; $i++) {
                $value = Get-Random -Minimum 0 -Maximum 255
                $hex += [byte]$value
            }
            return "#" + [System.Convert]::ToHexString($hex)
        }
    }
}

function Get-RandomList {
    param(
        [int] $MinItems = 2,
        [int] $MaxItems = 10,
        [scriptblock] $Generator = {
            Get-RandomString
        }
    )
    $items = @()
    $count = Get-Random -Minimum $MinItems -Maximum $MaxItems
    for ($i = 0; $i -lt $count; $i++) {
        $items += $Generator.Invoke()
    }
    return $items

}

function Get-RandomString {
    param (
        [int] $MinimumLength = 10,
        [int] $MaximumLength = 20
    )
    $length = Get-Random -Minimum $MinimumLength -Maximum $MaximumLength
    $chars = [char[]]([char]'a'..[char]'z' + [char]'A'..[char]'Z' + [char]'0'..[char]'9')
    $string = ""
    for ($i = 0; $i -lt $length; $i++) {
        $string += $chars[$(Get-Random -Minimum 0 -Maximum $chars.Count)]
    }
    return $string
}

function Get-RandomBoxBorder {
    $lookup = [BoxBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
    return $lookup[$(Get-Random -Minimum 0 -Maximum $lookup.Count)]
}

function Get-RandomJustify {
    $lookup = [Justify].GetEnumNames()
    return $lookup[$(Get-Random -Minimum 0 -Maximum $lookup.Count)]
}

function Get-RandomSpinner {
    $lookup = [Spinner+Known] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
    return $lookup[$(Get-Random -Minimum 0 -Maximum $lookup.Count)]
}

function Get-RandomTreeGuide {
    $lookup = [TreeGuide] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
    return $lookup[$(Get-Random -Minimum 0 -Maximum $lookup.Count)]
}

function Get-RandomTableBorder {
    $lookup = [TableBorder] | Get-Member -Static -MemberType Properties | Select-Object -ExpandProperty Name
    return $lookup[$(Get-Random -Minimum 0 -Maximum $lookup.Count)]
}

function Get-RandomChartItem {
    return New-SpectreChartItem -Label (Get-RandomString) -Value (Get-Random -Minimum -100 -Maximum 100) -Color (Get-RandomColor)
}

function Get-RandomTree {
    param(
        [hashtable] $Root,
        [int] $MinChildren = 1,
        [int] $MaxChildren = 3,
        [int] $MaxDepth = 5,
        [int] $CurrentDepth = 0
    )

    if ($CurrentDepth -gt $MaxDepth) {
        return $Root
    }

    $CurrentDepth++

    if ($null -eq $Root) {
        $Root = @{
            Label    = Get-RandomString
            Children = @()
        }
    }

    $children = Get-Random -Minimum $MinChildren -Maximum $MaxChildren
    for ($i = 0; $i -lt $children; $i++) {
        $newChild = @{
            Label    = Get-RandomString
            Children = @()
        }
        $newTree = Get-RandomTree -Root $newChild -MaxChildren $MaxChildren -MaxDepth $MaxDepth -CurrentDepth $CurrentDepth
        $Root.Children += $newTree
    }

    return $Root
}

function Get-RandomBool {
    return [bool](Get-Random -Minimum 0 -Maximum 2)
}

function Get-RandomChoice {
    param(
        [string[]] $Choices
    )
    return $Choices[(Get-Random -Minimum 0 -Maximum $Choices.Count)]
}

function Get-SpectreRenderable {
    param(
        [Parameter(Mandatory)]
        [Spectre.Console.Rendering.Renderable]$RenderableObject
    )
    try {
        $writer = [System.IO.StringWriter]::new()
        $output = [Spectre.Console.AnsiConsoleOutput]::new($writer)
        $settings = [Spectre.Console.AnsiConsoleSettings]::new()
        $settings.Out = $output
        $console = [Spectre.Console.AnsiConsole]::Create($settings)
        $console.Write($RenderableObject)
        $writer.ToString()
    }
    finally {
        $writer.Dispose()
    }
}

function Get-AnsiEscapeSequence {
    <#
        could be useful for debugging
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [String] $String
    )
    process {
        $Escaped = $String.EnumerateRunes() | ForEach-Object {
            if ($_.Value -le 0x1f) {
                [Text.Rune]::new($_.Value + 0x2400)
            }
            else {
                $_
            }
        } | Join-String
        [PSCustomObject]@{
            Escaped  = $Escaped
            Original = $String
            Clean    = [System.Management.Automation.Host.PSHostUserInterface]::GetOutputString($String, $false)
        }
    }
}
function StripAnsi {
    process {
        [System.Management.Automation.Host.PSHostUserInterface]::GetOutputString($_, $false)
    }
}

function Get-PSStyleRandom {
    param(
        [Switch] $Foreground,
        [Switch] $Background,
        [Switch] $Decoration,
        [Switch] $RGBForeground,
        [Switch] $RGBBackground
    )
    $Style = Switch ($PSBoundParameters.Keys) {
        'Foreground' {
            $fg = ($PSStyle.Foreground | Get-Member -MemberType Property | Get-Random).Name
            $PSStyle.Foreground.$fg
        }
        'Background' {
            $bg = ($PSStyle.Background | Get-Member -MemberType Property | Get-Random).Name
            $PSStyle.Background.$bg
        }
        'Decoration' {
            $deco = ($PSStyle | Get-Member -MemberType Property | Where-Object { $_.Definition -match '^string' -And $_.Name -notmatch 'off$|Reset' } | Get-Random).Name
            $PSStyle.$deco
        }
        'RGBForeground' {
            $r = Get-Random -min 0 -max 255
            $g = Get-Random -min 0 -max 255
            $b = Get-Random -min 0 -max 255
            $PSStyle.Foreground.FromRgb($r, $g, $b)
        }
        'RGBBackground' {
            $r = Get-Random -min 0 -max 255
            $g = Get-Random -min 0 -max 255
            $b = Get-Random -min 0 -max 255
            $PSStyle.Background.FromRgb($r, $g, $b)
        }
    }
    return $Style | Join-String
}
Function Get-SpectreColorSample {
    $spectreColors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
    foreach ($c in $spectreColors) {
        $color = [Spectre.Console.Color]::$c
        $renderable = [Spectre.Console.Text]::new("Hello, $c", [Spectre.Console.Style]::new($color))
        $SpectreString = Get-SpectreRenderable $renderable
        [PSCustomObject]@{
            Color  = $c
            String = $SpectreString
            # Object = $color
            # Debug = Get-AnsiEscapeSequence $SpectreString
        }
    }
}
function Get-SpectreTableRowData {
    param(
        [int]$Count = 5,
        [Switch]$Markup
    )
    if ($null -eq $count) {
        $count = 5
    }
    1..$Count | ForEach-Object {
        if ($Markup) {
            return '[{0}] {1} [/]' -f (Get-RandomColor), (Get-RandomString)
            }
        Get-RandomString
    }
}

function Assert-OutputMatchesSnapshot {
    param (
        [string] $SnapshotName,
        [string] $Output
    )
    $snapShotComparisonPath = "$PSScriptRoot\@snapshots\$SnapshotName.snapshot.compare.txt"
    $snapShotPath = "$PSScriptRoot\@snapshots\$SnapshotName.snapshot.txt"
    $compare = $Output -replace "`r", ""
    Set-Content -Path $snapShotComparisonPath -Value $compare -NoNewline
    $snapshot = Get-Content -Path $snapShotPath -Raw
    $snapshot = $snapshot -replace "`r", ""
    if($compare -ne $snapshot) {
        Write-Host "Expected to match snapshot:`n`n$snapshot"
        Write-Host "But the output was:`n`n$compare"
        Write-Host "You can diff the snapshot files at:`n - $snapShotPath`n - $snapShotComparisonPath"
        throw "Snapshot comparison failed"
    }
}