using namespace Spectre.Console

function Add-TableColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $table,
        $FormatData,
        [String] $Title,
        [switch] $ScalarDetected
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ($ScalarDetected -eq $true -or $Formatdata -eq 'Value') {
        if ($Title) {
            Write-Debug "Adding column with title: $Title"
            $table.AddColumn($Title) | Out-Null
        }
        else {
            Write-Debug "Adding column with title: Value"
            $table.AddColumn("Value") | Out-Null
        }
    }
    else {
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
    }
    return $table
}
