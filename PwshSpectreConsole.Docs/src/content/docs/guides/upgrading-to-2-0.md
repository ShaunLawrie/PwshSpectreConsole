---
title: Upgrading to 2.0
description: Breaking changes and stuff.
---

I started this as a learning excercise in how to bridge the gap between C# libraries and PowerShell and wow have I learned a lot. Things I thought made sense when I first wrote this have now made it difficult to maintain. I've tried to maintain as much backwards compatibility as I can but there are some areas which will have breaking changes when upgrading to 2.0.

## Breaking Changes

- Format-SpectreJson parameters removed are `-Border`, `-Title`, `-NoBorder`.  
  To wrap the json in a border you can now pipe the output to Format-SpectrePanel e.g. `Format-SpectreJson -Data $data | Format-SpectrePanel`

## New Features

🆕 New commandlets to make this PowerShell library compatible with the rest of the Spectre.Console C# library:

- [`Add-SpectreTableRow`](/reference/formatting/add-spectretablerow/) - Add a row to an existing table.
- [`Format-SpectreAligned`](/reference/formatting/format-spectrealigned/) - Set the alignment for an item inside a panel/layout.
- [`Format-SpectreColumns`](/reference/formatting/format-spectrecolumns/) - A convenience method for rendering an array of items in columns.
- [`Format-SpectreRows`](/reference/formatting/format-spectrerows/) - Render an array of items in rows.
- [`Format-SpectreGrid`](/reference/formatting/format-spectregrid/) - Render an array of items in a grid.
- [`New-SpectreGridRow`](/reference/formatting/new-spectregridrow/) - Create a new row for a grid from an array of columns.
- [`Format-SpectrePadded`](/reference/formatting/format-spectrepadded/) - Surround an item with spaced padding.
- [`Format-SpectreTextPath`](/reference/formatting/format-spectretextpath/) - Render a file/folder path with syntax highlighting.
- [`Format-SpectreException`](/reference/formatting/format-spectreexception/) - Render an exception with syntax highlighting.
- [`Invoke-SpectreLive`](/reference/live/invoke-spectrelive) - Run a scriptblock and update a renderable item live in real-time.

💲 Renderable items (markup, panels, tables etc.) use PowerShell formatters so you can now assign the output of functions like `Format-SpectreJson` to a variable and use it inside other Spectre Console functions like `Format-SpectreTable`.  
![renderable items inside tables](/PwshSpectreConsole.Docs/public/2-0-tables.png)

### What about the canvas widget?

The [canvas](https://spectreconsole.net/widgets/canvas) widget is low level enough that it doesn't make sense to implement in PowerShell. If you need to use it you can use the C# library directly e.g.

```powershell
# Create a canvas
$canvas = [Spectre.Console.Canvas]::new(16, 16)

# Draw some shapes
for($i = 0; $i -lt $canvas.Width; $i++) {
    # Cross
    $canvas = $canvas.SetPixel($i, $i, [Spectre.Console.Color]::White)
    $canvas = $canvas.SetPixel($canvas.Width - $i - 1, $i, [Spectre.Console.Color]::White)

    # Border
    $canvas = $canvas.SetPixel($i, 0, [Spectre.Console.Color]::Red)
    $canvas = $canvas.SetPixel(0, $i, [Spectre.Console.Color]::Green)
    $canvas = $canvas.SetPixel($i, $canvas.Height - 1, [Spectre.Console.Color]::Blue)
    $canvas = $canvas.SetPixel($canvas.Width - 1, $i, [Spectre.Console.Color]::Yellow)
}

# Render the canvas
$canvas | Out-SpectreHost
```
