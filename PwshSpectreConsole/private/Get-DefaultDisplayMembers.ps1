function Get-DefaultDisplayMembers {
    <#
    .SYNOPSIS
        Get the default display members for an object using the formatdata.
    .NOTES
    rewrite, borrowed some code from chrisdents gist.
    .LINK
    https://raw.githubusercontent.com/PowerShell/GraphicalTools/master/src/Microsoft.PowerShell.ConsoleGuiTools/TypeGetter.cs
    https://gist.github.com/indented-automation/834284b6c904339b0454199b4745237e

        #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [Object]$Object
    )
    try {
        Write-Debug "getting formatdata for $($Object[0].PSTypeNames)"
        $formatData = Get-FormatData -TypeName $Object[0].PSTypeNames | Select-Object -First 1
        Write-Debug "formatData: $($formatData.count)"
    }
    catch {
        # no formatdata found
        return $null
    }
    if ($formatData) {
        $properties = [ordered]@{}
        $labels = @{}
        # $regex = [regex]::New('(?x)\$_\.(?<Property>[^\s,]+)')
        $viewDefinition = $formatData.FormatViewDefinition | Where-Object { $_.Control -match 'TableControl' } | Select-Object -First 1
        Write-Debug "viewDefinition: $($viewDefinition.Name)"
        $format = for ($i = 0; $i -lt $viewDefinition.Control.Headers.Count; $i++) {
            $name = $viewDefinition.Control.Headers[$i].Label
            $displayEntry = $viewDefinition.Control.Rows.Columns[$i].DisplayEntry
            if (-not $name) {
                $name = $displayEntry.Value
            }
            if ($labels.ContainsKey($name)) {
                Write-Debug 'duplicate label found'
                # im not sure why this is needed, but for filesystem we get both 'Mode' and 'ModeWithoutHardLink' with "label" Mode.
                continue
            }
            $labels[$name] = $true
            switch ($displayEntry.ValueType) {
                'Property' {
                    $expression = $displayEntry.Value
                    # $property = $displayEntry.Value
                }
                'ScriptBlock' {
                    $expression = [ScriptBlock]::Create($displayEntry.Value)
                    # $property = $regex.matches($displayEntry.Value).foreach({ $_.Groups['Property'].Value }) | Select-Object -Unique
                }
            }
            $properties[$name] = @{
                Label     = $name
                Width     = $viewDefinition.Control.headers[$i].width
                Alignment = $viewDefinition.Control.headers[$i].alignment
                # Property  = $property
                # Expression   = $expression
                # PropertyType = $Object.PSObject.Properties[$property].TypeNameOfValue
                # Type         = $displayEntry.ValueType
            }
            @{ Name = $name; Expression = $expression }
        }
        # we still need the properties to create the columns, but this function can be simplified.
        # temporarily leaving it commented out for testing.
        return [PSCustomObject]@{
            Properties = $properties
            Format     = $format
        }
    }
}
