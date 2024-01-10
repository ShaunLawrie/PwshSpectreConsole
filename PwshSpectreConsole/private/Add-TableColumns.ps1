using namespace Spectre.Console

function Add-TableColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $table,
        [Parameter(Mandatory)]
        $Object,
        [Collections.Specialized.OrderedDictionary]
        $FormatData,
        [String[]]
        $Property,
        [String]
        $Title
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ($Property) {
        Write-Debug 'Adding column from property'
        foreach ($prop in $Property) {
            $table.AddColumn($prop) | Out-Null
        }
    } elseif ($FormatData) {
        foreach ($key in $FormatData.keys) {
            $lookup = $FormatData[$key]
            Write-Debug "Adding column from formatdata: $($lookup.GetEnumerator())"
            $table.AddColumn($lookup.Label) | Out-Null
            $table.Columns[-1].Padding = [Spectre.Console.Padding]::new(1, 0, 1, 0)
            if ($lookup.width -gt 0) {
                # width 0 is autosize, select the last entry in the column list
                $table.Columns[-1].Width = $lookup.Width
            }
            if ($lookup.Alignment -ne 'undefined') {
                $table.Columns[-1].Alignment = [Justify]::$lookup.Alignment
            }
        }
    } elseif (Test-IsScalar $Object) {
        # simple/scalar types show up wonky, we can detect them and just use a dummy header for the table
        Write-Debug 'simple/scalar type'
        $script:scalarDetected = $true
        if ($Title) {
            $table.AddColumn($Title) | Out-Null
        } else {
            $table.AddColumn("Value") | Out-Null
        }
    } else {
        # no formatting found and no properties selected, enumerating psobject.properties.name
        Write-Debug 'PSCustomObject/Properties switch detected'
        foreach ($prop in $Object.psobject.Properties.Name) {
            if (-Not [String]::IsNullOrEmpty($prop)) {
                $table.AddColumn($prop) | Out-Null
            }
        }
    }
    return $table
}
