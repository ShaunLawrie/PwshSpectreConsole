using namespace Spectre.Console

function Get-SpectreProfile {
    [CmdletBinding()]
    param ()
    $object = [AnsiConsole]::Profile
    return [PSCustomObject]@{
        Enrichers             = $object.Enrichers -join ', '
        ColorSystem           = $object.Capabilities.ColorSystem
        Unicode               = $object.Capabilities.Unicode
        Ansi                  = $object.Capabilities.Ansi
        Links                 = $object.Capabilities.Links
        Legacy                = $object.Capabilities.Legacy
        Interactive           = $object.Capabilities.Interactive
        Terminal              = $object.out.IsTerminal
        Writer                = $object.Out.Writer
        Width                 = $object.Width
        Height                = $object.Height
        Encoding              = $object.Encoding.EncodingName
        PSStyle               = $PSStyle.OutputRendering
        ConsoleOutputEncoding = [console]::OutputEncoding
        ConsoleInputEncoding  = [console]::InputEncoding
    }
}
