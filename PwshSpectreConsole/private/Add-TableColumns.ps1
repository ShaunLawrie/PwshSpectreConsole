using namespace Spectre.Console

function Add-TableColumns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [Table] $table,
        [Collections.Specialized.OrderedDictionary] $FormatData,
        [String] $Title,
        [Color] $Color = [Color]::Default,
        [Switch] $Scalar,
        [Switch] $Wrap
    )
    Write-Debug "Module: $($ExecutionContext.SessionState.Module.Name) Command: $($MyInvocation.MyCommand.Name) Param: $($PSBoundParameters.GetEnumerator())"
    if ($Scalar) {
        if ($Title) {
            Write-Debug "Adding column with title: $Title"
            $table.AddColumn("[$($Color.ToMarkup())]$Title[/]") | Out-Null
        }
        else {
            Write-Debug "Adding column with title: Value"
            $table.AddColumn("[$($Color.ToMarkup())]Value[/]") | Out-Null
        }
        if (-Not $Wrap) {
            $table.Columns[-1].NoWrap = $true
        }
    }
    else {
        foreach ($key in $FormatData.keys) {
            $lookup = $FormatData[$key]
            Write-Debug "Adding column from formatdata: $($lookup.GetEnumerator())"
            $table.AddColumn("[$($Color.ToMarkup())]$($lookup.Label)[/]") | Out-Null
            $table.Columns[-1].Padding = [Padding]::new(1, 0, 1, 0)
            if ($lookup.width -gt 0) {
                # width 0 is autosize, select the last entry in the column list
                $table.Columns[-1].Width = $lookup.Width
            }
            if ($lookup.Alignment -ne 'undefined') {
                $table.Columns[-1].Alignment = [Justify]::$lookup.Alignment
            }
            if (-Not $Wrap) {
                # https://github.com/spectreconsole/spectre.console/issues/1185
                # leaving it in as it will probably get fixed, has no effect on output yet.
                $table.Columns[-1].NoWrap = $true
            }
        }
    }
    return $table
}
