function ConvertTo-Renderable {
    param (
        [object] $InputData
    )

    # These objects are already renderable
    if ($InputData -is [Spectre.Console.Rendering.Renderable]) {
        return $InputData
    }

    $renderableItems = @()
    
    if ($InputData -is [array]) {
        foreach ($column in $InputData) {
            $renderableItems += ConvertTo-Renderable $column
        }
    } else {
        # For others just dump them as either strings formatted with markup which are easy to identify by the closing tag [/] or as plain text
        if ($InputData -like "*[/]*") {
            $renderableItems += [Spectre.Console.Markup]::new($InputData)
        } else {
            $renderableItems += [Spectre.Console.Text]::new(($InputData | Out-String -NoNewline))
        }
    }

    return $renderableItems
}