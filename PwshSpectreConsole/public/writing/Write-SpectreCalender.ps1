using module "..\..\private\completions\Completers.psm1"
using namespace Spectre.Console

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

    .EXAMPLE
    # This example shows how to use the Write-SpectreCalendar function with an events table defined as a hashtable in the command.
    Write-SpectreCalendar -Date 2024-07-01 -Events @{'2024-07-10' = 'Beach time!'; '2024-07-20' = 'Barbecue' }

    .EXAMPLE
    # This example shows how to use the Write-SpectreCalendar function with an events table as an object argument.
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
        [Color] $Color = $script:AccentColor,
        [ValidateSet([SpectreConsoleTableBorder],ErrorMessage = "Value '{0}' is invalid. Try one of: {1}")]
        [string] $Border = "Double",
        [cultureinfo] $Culture = [cultureinfo]::CurrentCulture,
        [Hashtable]$Events,
        [Switch] $HideHeader
    )
    $calendar = [Calendar]::new($date)
    $calendar.Alignment = [Justify]::$Alignment
    $calendar.Border = [TableBorder]::$Border
    $calendar.BorderStyle = [Style]::new($Color)
    $calendar.Culture = $Culture
    $calendar.HeaderStyle = [Style]::new($Color)
    $calendar.HighlightStyle = [Style]::new($Color)
    if ($HideHeader) {
        $calendar.ShowHeader = $false
    }
    if ($Events) {
        foreach ($event in $events.GetEnumerator()) {
            # calendar events doesnt appear to support Culture.
            $eventDate = $event.Name -as [datetime]
            $calendar = [CalendarExtensions]::AddCalendarEvent($calendar, $event.value, $eventDate.Year, $eventDate.Month, $eventDate.Day)
        }
        Write-AnsiConsole $calendar
        $calendar.CalendarEvents | Sort-Object -Property Day | Format-SpectreTable -Border $Border -Color $Color
    }
    else {
        Write-AnsiConsole $calendar
    }
}
