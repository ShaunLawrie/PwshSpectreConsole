using namespace Spectre.Console

function Get-RandomColor {
    $type = 1 # Get-Random -Minimum 0 -Maximum 2
    switch($type) {
        0 {
            $colors = [Spectre.Console.Color] | Get-Member -Static -Type Properties | Select-Object -ExpandProperty Name
            return $colors[$(Get-Random -Minimum 0 -Maximum $colors.Count)]
        }
        1 {
            $hex = @()
            for($i = 0; $i -lt 3; $i++) {
                $value = Get-Random -Minimum 0 -Maximum 255
                $hex += [byte]$value
            }
            return "#" + [System.Convert]::ToHexString($hex)
        }
    }
}

function Get-RandomList {
    param (
        [int] $MinItems = 2,
        [int] $MaxItems = 10,
        [scriptblock] $Generator = {
            Get-RandomString
        }
    )
    $items = @()
    $count = Get-Random -Minimum $MinItems -Maximum $MaxItems
    for($i = 0; $i -lt $count; $i++) {
        $items += $Generator.Invoke()
    }
    return $items

}

function Get-RandomString {
    $length = Get-Random -Minimum 1 -Maximum 20
    $chars = [char[]]([char]'a'..[char]'z' + [char]'A'..[char]'Z' + [char]'0'..[char]'9')
    $string = ""
    for($i = 0; $i -lt $length; $i++) {
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
    param (
        [hashtable] $Root,
        [int] $MinChildren = 1,
        [int] $MaxChildren = 3,
        [int] $MaxDepth = 5,
        [int] $CurrentDepth = 0
    )

    if($CurrentDepth -gt $MaxDepth) {
        return $Root
    }

    $CurrentDepth++

    if($null -eq $Root) {
        $Root = @{
            Label = Get-RandomString
            Children = @()
        }
    }

    $children = Get-Random -Minimum $MinChildren -Maximum $MaxChildren
    for($i = 0; $i -lt $children; $i++) {
        $newChild = @{
            Label = Get-RandomString
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
    param (
        [string[]] $Choices
    )
    return $Choices[(Get-Random -Minimum 0 -Maximum $Choices.Count)]
}