using module ".\attributes\ColorAttributes.psm1"

function Convert-ToSpectreColor {
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [ValidateSpectreColor()]
        [string] $Color
    )
    # Already validated in validation attribute
    if($Color.StartsWith("#")) {
        $hexString = $Color -replace '^#', ''
        $hexBytes = [System.Convert]::FromHexString($hexString)
        return [Spectre.Console.Color]::new($hexBytes[0], $hexBytes[1], $hexBytes[2])
    }

    # Validated in attribute as a real color already
    return [Spectre.Console.Color]::$Color
}
