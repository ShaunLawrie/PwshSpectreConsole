using module "..\..\private\completions\Transformers.psm1"

function Out-SpectreHost {
    <#
    .SYNOPSIS
    Writes a spectre renderable to the console host.

    .DESCRIPTION
    Out-SpectreHost writes a spectre renderable object to the console host.  
    This function is used to output spectre renderables to the console when you want to avoid the additional newlines that the PowerShell formatter adds.

    .PARAMETER Data
    The data to write to the console.

    .EXAMPLE
    $table = New-SpectreTable -Data $data
    $table | Out-SpectreHost
    #>
    [Reflection.AssemblyMetadata("title", "Out-SpectreHost")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $Data
    )

    begin {}

    process {
        if ($Data -is [array]) {
            foreach ($dataItem in $Data) {
                Write-AnsiConsole -RenderableObject $dataItem
            }
        } else {
            Write-AnsiConsole -RenderableObject $Data
        }
    }

    end {}
}