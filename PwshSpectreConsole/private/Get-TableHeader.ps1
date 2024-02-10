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
    process {
        $properties = [ordered]@{}
        @($FormatStartData.shapeInfo.tableColumnInfoList).Where{ $_ }.ForEach{
            $Name = $_.Label ? $_.Label : $_.propertyName
            $properties[$Name] = @{
                Label     = $Name
                Width     = $_.width
                Alignment = $_.alignment
            }
        }
        if ($properties.Keys.Count -eq 0) {
            Write-Debug "No properties found"
            return $null
        }
        return $properties
    }
}
