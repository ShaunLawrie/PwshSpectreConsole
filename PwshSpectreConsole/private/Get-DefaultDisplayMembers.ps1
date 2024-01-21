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
    } catch {
        # error getting formatdata, return null
        return $null
    }
    if (-Not $formatData) {
        # no formatdata, return null
        return $null
    }
    # this needs to ordered to preserve table column order.
    $properties = [ordered]@{}
    $viewDefinition = $formatData.FormatViewDefinition | Where-Object { $_.Control -match 'TableControl' } | Select-Object -First 1
    Write-Debug "viewDefinition: $($viewDefinition.Name)"
    $format = for ($i = 0; $i -lt $viewDefinition.Control.Headers.Count; $i++) {
        $name = $viewDefinition.Control.Headers[$i].Label
        $displayEntry = $viewDefinition.Control.Rows.Columns[$i].DisplayEntry
        if (-not $name) {
            $name = $displayEntry.Value
        }
        $expression = switch ($displayEntry.ValueType) {
            'Property' { $displayEntry.Value }
            'ScriptBlock' { [ScriptBlock]::Create($displayEntry.Value) }
        }
        $properties[$name] = @{
            Label     = $name
            Width     = $viewDefinition.Control.headers[$i].width
            Alignment = $viewDefinition.Control.headers[$i].alignment
        }
        @{ Name = $name; Expression = $expression }
    }
    return [PSCustomObject]@{
        Properties = $properties
        Format     = $format
    }
}
