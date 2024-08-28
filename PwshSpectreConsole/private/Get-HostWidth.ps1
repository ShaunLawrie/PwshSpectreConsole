# Required for unit test mocking
function Get-HostWidth {
    return [Spectre.Console.AnsiConsole]::Profile.Width
}