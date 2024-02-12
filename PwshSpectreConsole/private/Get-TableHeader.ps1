function Get-TableHeader {
    <#
        ls | ft | Get-TableHeader
        https://gist.github.com/Jaykul/9999be71ee68f3036dc2529c451729f4
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $FormatStartData
    )
    begin {
        $alignment = @{
            0 = 'undefined'
            1 = 'Left'
            2 = 'Center'
            3 = 'Right'
        }
    }
    process {
        $properties = [ordered]@{}
        $FormatStartData.shapeinfo.tablecolumninfolist | ForEach-Object {
            $Name = $_.Label ? $_.Label : $_.propertyName
            if ($Name) {
                $properties[$Name] = @{
                    Label                 = $Name
                    Width                 = $_.width
                    Alignment             = $alignment.ContainsKey($_.alignment) ? $alignment[$_.alignment] : 'undefined'
                    HeaderMatchesProperty = $_.HeaderMatchesProperty
                    PropertyName          = $_.propertyName
                }
            }
        }
        if ($properties.Keys.Count -eq 0) {
            Write-Debug "No properties found"
            return $null
        }
        return $properties
    }
}
