using module "..\..\private\completions\Transformers.psm1"

function Out-SpectreHost {
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/writing/out-spectrehost/')]
    <#
    .SYNOPSIS
    Writes a spectre renderable to the console host.

    .DESCRIPTION
    Out-SpectreHost writes a spectre renderable object to the console host.  
    This function is used to output spectre renderables to the console when you want to avoid the additional newlines that the PowerShell formatter adds.

    .PARAMETER Data
    The data to write to the console.

    .PARAMETER CustomItemFormatter
    The default host customitem formatter has some restrictions, it needs to be one char less wide than when outputting to the standard console or it will wrap.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to write a spectre renderable object to the console host.
    $table = Get-ChildItem | Select-Object Name, Length, LastWriteTime | Format-SpectreTable
    $table | Out-SpectreHost
    #>
    [Reflection.AssemblyMetadata("title", "Out-SpectreHost")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [switch] $CustomItemFormatter
    )

    begin {}

    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                Write-AnsiConsole -RenderableObject $dataItem -CustomItemFormatter:$CustomItemFormatter
            }
        } else {
            Write-AnsiConsole -RenderableObject $Data -CustomItemFormatter:$CustomItemFormatter
        }
    }

    end {}
}