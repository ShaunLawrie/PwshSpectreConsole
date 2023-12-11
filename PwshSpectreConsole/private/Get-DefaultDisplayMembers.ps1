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
    $properties = [ordered]@{}
    $labels = @{}
    try {
        $formatData = Get-FormatData -TypeName $Object[0].PSTypeNames | Select-Object -First 1
    }
    catch {
        # no formatdata found
        return $null
    }
    if ($formatData) {
        $viewDefinition = $formatData.FormatViewDefinition | Where-Object { $_.Control -match 'TableControl' }
        for ($i = 0; $i -lt $viewDefinition.Control.Headers.Count; $i++) {
            $name = $viewDefinition.Control.Headers[$i].Label
            $displayEntry = $viewDefinition.Control.Rows.Columns[$i].DisplayEntry
            if (-not $name) {
                $name = $displayEntry.Value
            }
            if ($labels.ContainsKey($name)) {
                # im not sure why this is needed, but for filesystem we get both 'Mode' and 'ModeWithoutHardLink' with "label" Mode.
                continue
            }
            $labels[$name] = $true
            switch ($displayEntry.ValueType) {
                'Property' {
                    $expression = $displayEntry.Value
                    $property = $displayEntry.Value
                }
                'ScriptBlock' {
                    $expression = [ScriptBlock]::Create($displayEntry.Value)
                    $property = [regex]::Match($displayEntry.Value, '(?x)\$_\.(?<Property>\w+)').Groups['Property'].Value
                }
            }
            $properties[$property] = @{
                Label        = $name
                Type         = $displayEntry.ValueType
                Property     = $property
                Expression   = $expression
                PropertyType = $Object.PSObject.Properties[$property].TypeNameOfValue
                Width        = $viewDefinition.Control.headers[$i].width
            }
        }
        return $properties
    }
}
