function Convert-HashtableToRenderSafePSObject {
    param(
        [object] $Hashtable,
        [hashtable] $Renderables
    )
    $customObject = [ordered]@{}
    foreach ($item in $Hashtable.GetEnumerator()) {
        if ($item.Value -is [hashtable] -or $item.Value -is [ordered]) {
            $item.Value = Convert-HashtableToRenderSafePSObject -Hashtable $item.Value
        } elseif ($item.Value -is [Spectre.Console.Rendering.Renderable]) {
            $renderableKey = "RENDERABLE__$([Guid]::NewGuid().Guid)"
            $Renderables[$renderableKey] = $item.Value
            $item.Value = $renderableKey
        }
        $customObject[$item.Key] = $item.Value
    }
    return [pscustomobject]$customObject
}