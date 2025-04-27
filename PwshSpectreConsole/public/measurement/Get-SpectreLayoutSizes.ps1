function Get-SpectreLayoutSizes {
    <#
    .SYNOPSIS
    Gets the width and height of all of the layouts in a Spectre Console Layout.

    .DESCRIPTION
    The Get-SpectreLayoutSizes function gets the height of a Spectre Console layout object and all of its children. The result is a hashtable where you can access the size details for each layout object by its name.  
    When using sizes you need to be aware that this may include the size of the border if you specified one so you may need to subtract the border size from the total dimensions.

    .PARAMETER Layout
    The root layout to calculate the size for including all of its children.

    .EXAMPLE
    # **Example 1**  
    # This example calculates the heights of all the layouts in a layout tree and tells you how high the content layout will be based on their ratios.

    $layout = New-SpectreLayout -Name "root" -Rows @(
        # Row 1
        (New-SpectreLayout -Name "title" -Ratio 1 -Data ("Title goes here" | Format-SpectrePanel -Expand)),
        # Row 2
        (New-SpectreLayout -Name "body" -Ratio 3 -Columns @(
            # Column 1
            (New-SpectreLayout -Name "left" -Ratio 1 -Data ("Left goes here" | Format-SpectrePanel -Expand)),
            # Column 2
            (New-SpectreLayout -Name "right" -Ratio 2 -Data ("Right goes here" | Format-SpectrePanel -Expand))
        ))
    )

    # Get the sizes of the layouts in the layout tree before populating them with data
    $sizes = $layout | Get-SpectreLayoutSizes
    
    # Subtract the border sizes!
    $titleWidth = $sizes["title"].Width - 2
    $titleHeight = $sizes["title"].Height - 2
    $leftWidth = $sizes["left"].Width - 2
    $leftHeight = $sizes["left"].Height - 2
    $rightWidth = $sizes["right"].Width - 2
    $rightHeight = $sizes["right"].Height - 2

    # Populate the layouts with data that takes up the full height of the layout
    $titleContent = ((1..($titleHeight + 1)) | ForEach-Object { "Title line $_" }) -join "`n"
    $leftContent = ((1..($leftHeight + 1)) | ForEach-Object { "Left line $_" }) -join "`n"
    $rightContent = ((1..($rightHeight + 1)) | ForEach-Object { "Right line $_" }) -join "`n"

    $null = $layout["title"].Update(($titleContent | Format-SpectrePanel -Title "I am $titleWidth x $titleHeight" -Expand))
    $null = $layout["left"].Update(($leftContent | Format-SpectrePanel -Title "I am $leftWidth x $leftHeight" -Expand))
    $null = $layout["right"].Update(($rightContent | Format-SpectrePanel -Title "I am $rightWidth x $rightHeight" -Expand))
    
    $layout | Out-SpectreHost
    
    #>
    [CmdletBinding(HelpUri='https://pwshspectreconsole.com/reference/measurement/get-spectrelayoutsizes/')]
    [Reflection.AssemblyMetadata("title", "Get-SpectreLayoutSizes")]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        [Spectre.Console.Layout] $Layout
    )
    
    $size = [Spectre.Console.Size]::new($script:SpectreConsole.Profile.Width, $script:SpectreConsole.Profile.Height)
    $renderOptions = [Spectre.Console.Rendering.RenderOptions]::new(
        $script:SpectreConsole.Profile.Capabilities,
        $size
    )

    $regions = $layout.GetLayoutRegions($renderOptions, $renderOptions.ConsoleSize.Width)

    $regionsTable = @{}
    $regions.GetEnumerator() | Foreach-Object {
       $regionsTable[$_.Key] = $_.Value
    }
    
    return $regionsTable
}