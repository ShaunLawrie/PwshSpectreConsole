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
        Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
        $alignment = @{
            0 = 'undefined'
            1 = 'Left'
            2 = 'Center'
            3 = 'Right'
        }
    }
    process {
        if ($FormatStartData.Gettype().Name -eq 'FormatStartData') {
            $properties = [ordered]@{}
            $FormatStartData.shapeinfo.tablecolumninfolist | Where-Object { $_ } | ForEach-Object {
                $Name = $_.Label ? $_.Label : $_.propertyName
                $properties[$Name] = @{
                    Label                 = $Name
                    Width                 = $_.width
                    Alignment             = $alignment.Contains($_.alignment) ? $alignment[$_.alignment] : 'undefined'
                    HeaderMatchesProperty = $_.HeaderMatchesProperty
                    # PropertyName          = $_.propertyName
                }
            }
            if ($properties.Keys.Count -eq 0) {
                Write-Debug "No properties found"
                return $null
            }
            return $properties
        }
    }
}
