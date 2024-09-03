<#
.SYNOPSIS
    Demonstrates the features of Spectre.Console.

.DESCRIPTION
    This script demonstrates the features of Spectre.Console. It shows off the various colors, styles, and other features that Spectre.Console supports.

.EXAMPLE
    # **Example 1**  
    # This example demonstrates how to use Get-SpectreDemoFeatures to display a list of the features of Spectre.Console as seen on the https://spectreconsole.net/ homepage.
    Get-SpectreDemoFeatures
#>
function Get-SpectreDemoFeatures {
    [Reflection.AssemblyMetadata("title", "Get-SpectreDemoFeatures")]
    param ()

    $demoWidth = Get-HostWidth

    $title = Write-SpectreHost "[underline][yellow]PwshSpectreConsole[/][silver] Features[/][/]" -PassThru | Format-SpectreAligned -VerticalAlignment Middle
    $titleTable = Format-SpectreTable -Data @{
        Title = $title
    } -HideHeaders -Border None -Width $demoWidth
    
    $titleTable | Format-SpectrePadded -Top 1 -Left 0 -Bottom 0 -Right 0 | Out-SpectreHost
    
    # Colors
    $colors = @()
    $colors += Write-SpectreHost "[silver]✓[/] [red]2-bit color[/]" -PassThru
    $colors += Write-SpectreHost "[silver]✓[/] [green]3-bit color[/]" -PassThru
    $colors += Write-SpectreHost "[silver]✓[/] [blue]4-bit color[/]" -PassThru
    $colors += Write-SpectreHost "[silver]✓[/] [violet]8-bit color[/]" -PassThru
    $colors += Write-SpectreHost "[silver]✓[/] [yellow]Truecolor (16.7 million)[/]" -PassThru
    $colors += Write-SpectreHost "[silver]✓[/] [cyan]Automatic color conversion[/] " -PassThru
    $colorRows = $colors | Format-SpectreRows
    
    # Spectrum
    $spectrumRows = @()
    $brightnesses = 12
    $hues = $demoWidth - 52
    for ($b = 1; $b -le $brightnesses; $b+=2) {
        $line = ""
        for ($h = 0; $h -lt $hues; $h++) {
            $rgb1 = Convert-HslToRgb -Hue ($h * 360 / $hues) -Saturation 100 -Lightness (($b * 95) / $brightnesses)
            $color1 = [Spectre.Console.Color]::new($rgb1[0], $rgb1[1], $rgb1[2])
            $rgb2 = Convert-HslToRgb -Hue ($h * 360 / $hues) -Saturation 100 -Lightness ((($b + 1) * 95) / $brightnesses)
            $color2 = [Spectre.Console.Color]::new($rgb2[0], $rgb2[1], $rgb2[2])
            $line += "[#$($color2.ToHex()) on #$($color1.ToHex())]$([char]0x2584)[/]"
        }
        $spectrumRows += Write-SpectreHost $line -PassThru
    }
    $spectrumRows = $spectrumRows | Format-SpectreRows
    $colorColumns = Format-SpectreColumns -Data @(
        $colorRows,
        $spectrumRows
    )

    # Start the table creation
    $table = Format-SpectreTable -Data ([ordered]@{
        Feature = (Write-SpectreHost "[red]Colors[/]                         " -PassThru) # Force column width to be wide enough for the longest line
        Demo = $colorColumns
    }) -HideHeaders -Border None -Width $demoWidth
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # OS
    $os = Write-SpectreHost "[green]Windows[/] [blue]macOS[/] [yellow]Linux[/]" -PassThru
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]OS[/]" -PassThru), $os)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Styles
    $styles = Write-SpectreHost "[silver]All ansi styles[/] [bold]bold[/], [dim]dim[/], [italic]italic[/], [underline]underline[/], [strikethrough]strikethrough[/], [reverse]reverse[/], and even [rapidblink]blink[/]" -PassThru
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Styles[/]" -PassThru), $styles)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Wrap
    $wrapRows = @()
    $wrapRows += Write-SpectreHost "[silver]Word wrap text. Justify[/] [green]left[/], [yellow]center[/], or [blue]right[/]" -PassThru
    $wrapRows += ""
    $textToWrap = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque nec blandit quam. Vestibulum sed turpis eget metus feugiat imperdiet. Quisque tempor cursus nibh vitae maximus."
    $wrapRows += New-SpectreGridRow -Data @(
        (Write-SpectreHost "[green]$textToWrap[/]" -PassThru | Format-SpectreAligned -HorizontalAlignment Left),
        (Write-SpectreHost "[yellow]$textToWrap[/]" -PassThru | Format-SpectreAligned -HorizontalAlignment Center),
        (Write-SpectreHost "[blue]$textToWrap[/]" -PassThru | Format-SpectreAligned -HorizontalAlignment Right)
    ) | Format-SpectreGrid -Width $demoWidth
    $wrapRows = $wrapRows | Format-SpectreRows
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Wrap[/]" -PassThru), $wrapRows)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Markup
    $markup = Write-SpectreHost "[violet]Spectre.Console[/] supports a simple bbcode like [bold]markup[/] for [yellow]color[/], [underline]style[/], and emoji! :thumbs_up: :red_apple: :ant: :bear: :baguette_bread: :bus:" -PassThru

    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Markup[/]" -PassThru), $markup)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Tables and trees
    $embeddedTable = @(
        ([ordered]@{
            Foo = "Baz  "
            Bar = @(
                (Write-SpectreHost "`n[grey]Overview[/]" -PassThru),
                (Write-SpectreRule -Color Silver -PassThru),
                (@{
                    Value = "📁 src"
                    Children = @(
                        @{
                            Value = "📁 foo"
                            Children = @(
                                @{
                                    Value = "📄 bar.cs"
                                }
                            )
                        },
                        @{
                            Value = "📁 baz"
                            Children = @(
                                @{
                                    Value = "📁 qux"
                                    Children = @(
                                        @{
                                            Value = "📄 corgi.txt"
                                        }
                                    )
                                }
                            )
                        },
                        @{
                            Value = "📄 waldo.xml"
                        }
                    )
                } | Format-SpectreTree),
                (Write-SpectreRule -Color Silver -PassThru),
                (Write-SpectreHost "[grey]3 Files, 225 KiB[/]" -PassThru)
            ) | Format-SpectreRows
        }),
        ([ordered]@{
            Foo = ""
            Bar = ""
        })
        ([ordered]@{
            Foo = "Qux"
            Bar = "Corgi"
        })
     ) | Format-SpectreTable -Color Yellow -Width ($demoWidth - 22)
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Tables and Trees[/]" -PassThru), $embeddedTable)

    # Charts
    $breakdownChart = @(
        (New-SpectreChartItem -Label "PowerShell" -Value 70.2 -Color Blue),
        (New-SpectreChartItem -Label "MDX" -Value 24.7 -Color Red),
        (New-SpectreChartItem -Label "C#" -Value 3 -Color Green),
        (New-SpectreChartItem -Label "Astro" -Value 3 -Color Blue)
    ) | Format-SpectreBreakdownChart -ShowPercentage -Width ([int](($demoWidth - 30) / 2)) | Format-SpectrePanel -Border Square -Color Grey -Height 5

    $barChart = @(
        (New-SpectreChartItem -Label "Apple" -Value 32 -Color Green),
        (New-SpectreChartItem -Label "Oranges" -Value 13 -Color Orange1),
        (New-SpectreChartItem -Label "Bananas" -Value 22 -Color Yellow)
    ) | Format-SpectreBarChart -Width ([int](($demoWidth - 30) / 2) - 1) | Format-SpectrePanel -Border Square -Color Grey

    $chartColumns = Format-SpectreColumns -Data @(
        $breakdownChart,
        $barChart
    )

    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Charts[/]" -PassThru), $chartColumns)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Exceptions
    $exceptionData = $null
    try {
        Get-ChildItem -BadParam -ErrorAction Stop
    } catch {
        $exceptionData = $_ | Format-SpectreException -ExceptionFormat ShortenEverything
    }
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]Exceptions[/]" -PassThru), $exceptionData)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    # Much more
    $more = @(
        (Write-SpectreHost "Tables, Grids, Trees, Progress bars, Status, Bar charts, Calendars, Figlet, Images," -PassThru),
        (Write-SpectreHost "Text prompts, List boxes, Separators, Pretty exceptions, Canvas" -PassThru)
    ) | Format-SpectreRows
    $table = Add-SpectreTableRow -Table $table -Columns @((Write-SpectreHost "[red]+ Much More![/]" -PassThru), $more)
    $table = Add-SpectreTableRow -Table $table -Columns @("", "")

    $table | Format-SpectrePadded -Top 1 -Left 0 -Bottom 0 -Right 0 | Out-SpectreHost

    Write-SpectreHost " "
}