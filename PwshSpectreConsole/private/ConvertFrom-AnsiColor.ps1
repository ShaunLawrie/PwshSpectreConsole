function ConvertFrom-AnsiColor {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Text
    )
    process {
        # Regex to match ANSI escape sequences and determine their type
        $typeRegex = [regex]::new('\x1B\[(?<type>\d+);(?<format>\d)')
        # Regexes to match each type of ANSI escape sequence
        $rgbRegex = [regex]::new('\x1B\[(38|48);2;(?<r>\d{1,3});(?<g>\d{1,3});(?<b>\d{1,3})m')
        $colorRegex = [regex]::new('\x1B\[(38|48);5;(?<Color>\d+)m')
        if ($Text -match $typeRegex) {
            $type = $matches['type'] -as [byte]
            $format = $matches['format'] -as [byte]
            # Write-Debug "Type: $type, format: $format"
            if ($type -in 38,48) {
                if ($format -eq 2) {
                    # RGB
                    if ($text -match $rgbRegex) {
                        $rgb = $matches['r'], $matches['g'], $matches['b']
                        return [Spectre.Console.Color]::new($rgb[0], $rgb[1], $rgb[2])
                    }
                }
                elseif ($format -eq 5) {
                    # 256 color
                    if ($text -match $colorRegex) {
                        [byte]$concolor = $matches['color']
                        if ($concolor -gt 0 -and $concolor -le 15) {
                            return [Spectre.Console.Color]::FromConsoleColor($concolor)
                        }
                        elseif ($concolor -gt 15) {
                            return [Spectre.Console.Color]::FromInt32($concolor)
                        }
                        else {
                            return [Spectre.Console.Color]::Default
                        }
                    }
                }
            }
            else {
                if ($type -gt 0 -and $type -le 15) {
                    return [Spectre.Console.Color]::FromConsoleColor($type)
                }
                else {
                    return [Spectre.Console.Color]::FromInt32($type)
                }
            }
        }
    }
}
