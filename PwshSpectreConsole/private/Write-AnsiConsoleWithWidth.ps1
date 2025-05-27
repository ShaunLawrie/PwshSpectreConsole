using module ".\completions\Transformers.psm1"

<#
.SYNOPSIS
Writes an object to the console using Spectre.Console with a specific width

.DESCRIPTION
This function writes a renderable object to the console with a specific width.

.PARAMETER RenderableObject
The renderable object to write to the console e.g. [Spectre.Console.Rule]

.PARAMETER MaxWidth
The maximum width to use for rendering

.EXAMPLE
Write-AnsiConsoleWithWidth -RenderableObject $rule -MaxWidth 40
#>
function Write-AnsiConsoleWithWidth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [RenderableTransformationAttribute()]
        [object] $RenderableObject,
        
        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int] $MaxWidth
    )

    if ($script:SpectreRecordingType) {
        # Save the original width
        $originalWidth = [Spectre.Console.AnsiConsole]::Console.Profile.Width
        
        try {
            # Set the temporary width for recording
            [Spectre.Console.AnsiConsole]::Console.Profile.Width = $MaxWidth
            
            # Write with the adjusted width
            [Spectre.Console.AnsiConsole]::Write($RenderableObject)
            return
        }
        finally {
            # Restore the original width
            [Spectre.Console.AnsiConsole]::Console.Profile.Width = $originalWidth
        }
    }

    # Save the original width
    $originalWidth = $script:SpectreConsole.Profile.Width
    
    try {
        # Set the temporary width for rendering
        $script:SpectreConsole.Profile.Width = $MaxWidth
        
        # Render the object
        $script:SpectreConsole.Write($RenderableObject)
        $output = $script:SpectreConsoleWriter.ToString().TrimEnd()
        $null = $script:SpectreConsoleWriter.GetStringBuilder().Clear()
        
        return $output
    }
    finally {
        # Restore the original width
        $script:SpectreConsole.Profile.Width = $originalWidth
    }
}