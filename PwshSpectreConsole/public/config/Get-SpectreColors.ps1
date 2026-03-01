
function Get-SpectreColors {
    <#
    .SYNOPSIS
    Gets the current default colors for Spectre Console.

    .DESCRIPTION
    This function returns the current default color configuration for Spectre Console. These colors are used throughout the module as defaults for various commands. The colors can be changed using Set-SpectreColors.

    .EXAMPLE
    # **Example 1**  
    # This example demonstrates how to retrieve the current default colors for Spectre Console.
    Get-SpectreColors | Format-SpectreTable

    .EXAMPLE
    # **Example 2**  
    # This example demonstrates how to retrieve the default colors after changing them with Set-SpectreColors.
    Set-SpectreColors -AccentColor "Turquoise2" -DefaultValueColor "Grey85"
    Get-SpectreColors | Format-SpectreTable
    Set-SpectreColors -AccentColor "Blue" -DefaultValueColor "Grey"

    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/config/get-spectrecolors/')]
    [Reflection.AssemblyMetadata("title", "Get-SpectreColors")]
    param ()
    return [PSCustomObject]@{
        AccentColor           = $script:AccentColor
        DefaultValueColor     = $script:DefaultValueColor
        DefaultTableHeaderColor = $script:DefaultTableHeaderColor
        DefaultTableTextColor = $script:DefaultTableTextColor
    }
}
