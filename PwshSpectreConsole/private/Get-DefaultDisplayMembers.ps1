function Get-DefaultDisplayMembers {
    <#
    .SYNOPSIS
        Get the default display members for an object, attempts to use the extended type definition if available

    .NOTES
    //Use the TypeDefinition Label if availble otherwise just use the property name as a label

    .LINK
    https://raw.githubusercontent.com/PowerShell/GraphicalTools/master/src/Microsoft.PowerShell.ConsoleGuiTools/TypeGetter.cs

        #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Object]$Object
    )
    process {
        $typeName = $Object.PSObject.TypeNames
        $types = Get-FormatData -TypeName $typeName -ErrorAction SilentlyContinue
        if ($null -eq $types) {
            $types = Get-FormatData -TypeName $typeName -PowerShellVersion $PSVersionTable.PSVersion -ErrorAction SilentlyContinue
            if ($null -eq $types -or $types.Count -eq 0) {
                $pscustom = foreach ($prop in $Object.PSObject.Properties) {
                    if ($prop.IsGettable -eq $false -or $prop.Value -eq $false) {
                        continue
                    }
                    [pscustomobject]@{
                        Label = $prop.Name
                        Property = $prop.Name
                        Value = $prop.Value
                        PropertyType = $prop.TypeNameOfValue
                    }
                }
                return $pscustom
            }
        }
        $ExtendedTypeDefinition = $types[0].psbase.FormatViewDefinition[0].control
        $ExtendedTypeDefinition | ForEach-Object {
            $headers = $_.headers.label
            $values = $_.Rows[0].Columns | ForEach-Object { $_.DisplayEntry.Value }
            for ($i=0; $i -lt $headers.Count; $i++) {
                $currentHeader = $headers[$i]
                $currentValue = $values[$i]
                $backingPropertyName = [regex]::Match($currentValue, '(?x)\$_\.(?<Property>\w+)').Groups['Property'].Value
                if ([String]::IsNullOrEmpty($backingPropertyName)) {
                    $backingPropertyName = $currentValue
                }
                if ([String]::IsNullOrEmpty($currentHeader)) {
                    $currentHeader = $backingPropertyName
                }
                [pscustomobject]@{
                    Label = $currentHeader
                    Property = $backingPropertyName
                    Value = $currentValue
                    PropertyType = $Object.PSObject.Properties[$backingPropertyName].TypeNameOfValue
                }
            }
        }
    }
}
