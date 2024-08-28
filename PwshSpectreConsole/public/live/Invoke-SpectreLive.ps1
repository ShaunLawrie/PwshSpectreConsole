<#
.SYNOPSIS
Invokes a script block with live rendering.

.DESCRIPTION
Starts live rendering for a given renderable. The script block is able to update the renderable in real-time and Spectre Console redraws every time the scriptblock calls $Context.refresh().  
See https://spectreconsole.net/live/live-display for more information.

.PARAMETER Data
The renderable object to render.

.PARAMETER ScriptBlock
The script block to execute while the live renderable is being rendered.

.EXAMPLE
$data = @(
    [pscustomobject]@{Name="John"; Age=25; City="New York"},
    [pscustomobject]@{Name="Jane"; Age=30; City="Los Angeles"}
)
$table = Format-SpectreTable -Data $data

Invoke-SpectreLive -Data $table -ScriptBlock {
    param (
        $Context
    )
    $Context.refresh()
    for ($i = 0; $i -lt 5; $i++) {
        Start-Sleep -Seconds 1
        $table = Add-SpectreTableRow -Table $table -Columns "Shaun $i", $i, "Wellington"
        $Context.refresh()
    }
}
#>
function Invoke-SpectreLive {
    [Reflection.AssemblyMetadata("title", "Invoke-SpectreLive")]
    param (
        [Parameter(ValueFromPipeline)]
        [RenderableTransformationAttribute()]
        [object] $Data,
        [scriptblock] $ScriptBlock
    )

    Start-AnsiConsoleLive -Data $Data -ScriptBlock $ScriptBlock
}