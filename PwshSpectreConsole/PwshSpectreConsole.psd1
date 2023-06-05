@{
    ModuleVersion = '0.2.2'
    GUID = '8c5ca00d-7f0f-4179-98bf-bdaebceaebc0'
    Author = 'Shaun Lawrie'
    CompanyName = 'Shaun Lawrie'
    Copyright = '(c) Shaun Lawrie. All rights reserved.'
    Description = 'A convenient PowerShell wrapper for Spectre.Console'
    PowerShellVersion = '7.0'
    RootModule = 'PwshSpectreConsole'
    FunctionsToExport = @(
        'Add-SpectreJob',
        'Format-SpectreBarChart',
        'Format-SpectreBreakdownChart',
        'Format-SpectrePanel',
        'Format-SpectreTable',
        'Format-SpectreTree',
        'Get-SpectreImage',
        'Get-SpectreImageExperimental',
        'Invoke-SpectreCommandWithProgress',
        'Invoke-SpectreCommandWithStatus',
        'Invoke-SpectrePromptAsync',
        'Read-SpectreMultiSelection',
        'Read-SpectreMultiSelectionGrouped',
        'Read-SpectrePause',
        'Read-SpectreSelection',
        'Read-SpectreText',
        'Set-SpectreColors',
        'Start-SpectreDemo',
        'Wait-SpectreJobs',
        'Write-SpectreFigletText',
        'Write-SpectreHost',
        'Write-SpectreParagraph',
        'Write-SpectreRule'
    )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @("Windows", "Linux")
            LicenseUri = 'https://github.com/ShaunLawrie/PwshSpectreConsole/blob/main/LICENSE.md'
            ProjectUri = 'https://github.com/ShaunLawrie/PwshSpectreConsole'
            IconUri = 'https://shaunlawrie.com/images/pwshspectreconsole.png'
        }
    }
}