using module "..\..\private\completions\Completers.psm1"
using module "..\..\private\completions\Transformers.psm1"

function Write-SpectreCalendar {
    <#
    .SYNOPSIS
    Writes a Spectre Console Calendar text to the console.

    .DESCRIPTION
    Writes a Spectre Console Calendar text to the console.

    .PARAMETER Date
    The date to display the calendar for.

    .PARAMETER Alignment
    The alignment of the calendar.

    .PARAMETER Color
    The color of the calendar.

    .PARAMETER Border
    The border of the calendar.

    .PARAMETER Culture
    The culture of the calendar.

    .PARAMETER Events
    The events to highlight on the calendar.
    Takes a hashtable with the date as the key and the event as the value.

    .PARAMETER HideHeader
    Hides the header of the calendar. (Date)

    .PARAMETER PassThru
    Returns the Spectre Calendar object instead of writing it to the console.

    .EXAMPLE
    Write-SpectreCalendar -Date 2024-07-01 -Events @{'2024-07-10' = 'Beach time!'; '2024-07-20' = 'Barbecue' }

    .EXAMPLE
    $events = @{
        '2024-01-10' = 'Hello World!'
        '2024-01-20' = 'Hello Universe!'
    }
    Write-SpectreCalendar -Date 2024-01-01 -Events $events
    #>
    [Reflection.AssemblyMetadata("title", "Write-SpectreCalendar")]
    param (
        [datetime] $Date = [datetime]::Now,
        [ValidateSet([SpectreConsoleJustify], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Alignment = "Left",
        [ColorTransformationAttribute()]
        [ArgumentCompletionsSpectreColors()]
        [Spectre.Console.Color] $Color = $script:AccentColor,
        [ValidateSet([SpectreConsoleTableBorder], ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [cultureinfo] $Culture = [cultureinfo]::CurrentCulture,
        [Hashtable]$Events,
        [Switch] $HideHeader,
        [Switch] $PassThru
    )
    $calendar = [Spectre.Console.Calendar]::new($date)
    $calendar.Alignment = [Spectre.Console.Justify]::$Alignment
    $calendar.Border = [Spectre.Console.TableBorder]::$Border
    $calendar.BorderStyle = [Spectre.Console.Style]::new($Color)
    $calendar.Culture = $Culture
    $calendar.HeaderStyle = [Spectre.Console.Style]::new($Color)
    $calendar.HighlightStyle = [Spectre.Console.Style]::new($Color)
    if ($HideHeader) {
        $calendar.ShowHeader = $false
    }

    $outputData = @($calendar)

    if ($Events) {
        foreach ($event in $events.GetEnumerator()) {
            # Calendar events don't appear to support Culture.
            $eventDate = $event.Name -as [datetime]
            $calendar = [Spectre.Console.CalendarExtensions]::AddCalendarEvent($calendar, $event.value, $eventDate.Year, $eventDate.Month, $eventDate.Day)
        }
        $outputData += $calendar.CalendarEvents | Sort-Object -Property Day | Format-SpectreTable -Border $Border -Color $Color
    }

    if ($PassThru) {
        return $outputData
    }
    
    $outputData | Out-SpectreHost
}
