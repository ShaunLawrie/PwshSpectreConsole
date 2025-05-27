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
        # For recording, we'll try to set the width if possible
        $recordingConsole = [Spectre.Console.AnsiConsole]::Console
        
        # Try to get the profile width property safely
        $originalWidth = $null
        $canSetWidth = $false
        
        try {
            # Check if the console has a Profile.Width property
            if ($null -ne $recordingConsole.Profile -and 
                ($recordingConsole.Profile | Get-Member -Name 'Width' -MemberType Property)) {
                $originalWidth = $recordingConsole.Profile.Width
                $canSetWidth = $true
            }
        }
        catch {
            # If any error occurs, we'll just proceed without setting the width
            Write-Verbose "Unable to access Profile.Width property on recording console: $_"
        }
        
        try {
            # Set width if possible
            if ($canSetWidth) {
                $recordingConsole.Profile.Width = $MaxWidth
            }
            
            # Render the object
            [Spectre.Console.AnsiConsole]::Write($RenderableObject)
        }
        finally {
            # Restore original width if we changed it
            if ($canSetWidth -and $null -ne $originalWidth) {
                try {
                    $recordingConsole.Profile.Width = $originalWidth
                }
                catch {
                    Write-Verbose "Unable to restore Profile.Width on recording console: $_"
                }
            }
        }
        
        return
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