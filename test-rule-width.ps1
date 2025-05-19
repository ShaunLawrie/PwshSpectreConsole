Import-Module "$PSScriptRoot/PwshSpectreConsole/PwshSpectreConsole.psd1" -Force

Write-Host "Testing Write-SpectreRule with default width"
Write-SpectreRule -Title "Default Width Rule"

Write-Host "`nTesting Write-SpectreRule with fixed width"
Write-SpectreRule -Title "Fixed Width Rule (40 characters)" -Width 40

Write-Host "`nTesting Write-SpectreRule with percentage width"
Write-SpectreRule -Title "Half Width Rule (50%)" -Width "50%" -Alignment Center

Write-Host "`nTesting Write-SpectreRule with percentage width and right alignment"
Write-SpectreRule -Title "30% Width Rule (Right aligned)" -Width "30%" -Alignment Right

$consoleWidth = [Spectre.Console.AnsiConsole]::Profile.Width
Write-Host "`nConsole width is: $consoleWidth characters"