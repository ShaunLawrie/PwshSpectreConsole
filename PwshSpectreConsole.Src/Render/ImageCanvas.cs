using System;
using System.Collections.Generic;
using System.Linq;
using Spectre.Console;
using Spectre.Console.Rendering;

namespace PwshSpectreConsole;

/// <summary>
/// Represents a renderable canvas.
/// </summary>
public sealed class ImageCanvas : Renderable {
    private struct Cell {
        public char Glyph;
        public Color? Foreground;
        public Color? Background;
    }

    private readonly Cell[,] _cells;

    /// <summary>
    /// Gets the width of the canvas.
    /// </summary>
    public int Width { get; }

    /// <summary>
    /// Gets the height of the canvas.
    /// </summary>
    public int Height { get; }

    /// <summary>
    /// Gets or sets the render width of the canvas.
    /// </summary>
    public int? MaxWidth { get; set; }

    /// <summary>
    /// Gets or sets a value indicating whether or not
    /// to scale the canvas when rendering.
    /// </summary>
    public bool Scale { get; set; } = true;

    /// <summary>
    /// Gets or sets the pixel width.
    /// </summary>
    public int PixelWidth { get; set; } = 2;

    /// <summary>
    /// Initializes a new instance of the <see cref="Canvas"/> class.
    /// </summary>
    /// <param name="width">The canvas width.</param>
    /// <param name="height">The canvas height.</param>
    public ImageCanvas(int width, int height) {
        if (width < 1) {
            throw new ArgumentException("Must be > 1", nameof(width));
        }

        if (height < 1) {
            throw new ArgumentException("Must be > 1", nameof(height));
        }

        Width = width;
        Height = height;

        _cells = new Cell[Width, Height];
    }

    /// <summary>
    /// Sets a pixel with the specified color in the canvas at the specified location.
    /// </summary>
    /// <param name="x">The X coordinate for the pixel.</param>
    /// <param name="y">The Y coordinate for the pixel.</param>
    /// <param name="color">The pixel color.</param>
    /// <returns>The same <see cref="Canvas"/> instance so that multiple calls can be chained.</returns>
    /// <exception cref="ArgumentOutOfRangeException"></exception>
    public ImageCanvas SetCell(int x, int y, char glyph, Color? cellColor) {
        if (x < 0 || x >= Width || y < 0 || y >= Height) {
            throw new ArgumentOutOfRangeException($"SetCell x/y out of bounds: ({x},{y}) for canvas {Width}x{Height}");
        }

        _cells[x, y].Glyph = glyph;
        _cells[x, y].Foreground = cellColor;
        return this;
    }
    public ImageCanvas SetCell(int x, int y, char glyph, Color? foreground, Color? background) {
        if (x < 0 || x >= Width || y < 0 || y >= Height) {
            throw new ArgumentOutOfRangeException($"SetCell x/y out of bounds: ({x},{y}) for canvas {Width}x{Height}");
        }

        _cells[x, y].Glyph = glyph;
        _cells[x, y].Foreground = foreground;
        _cells[x, y].Background = background;
        return this;
    }

    /// <inheritdoc/>
    protected override Measurement Measure(RenderOptions options, int maxWidth) {
        if (PixelWidth < 0) {
            throw new InvalidOperationException("Pixel width must be greater than zero.");
        }

        int width = MaxWidth ?? Width;

        return maxWidth < width * PixelWidth ? new Measurement(maxWidth, maxWidth) : new Measurement(width * PixelWidth, width * PixelWidth);
    }

    /// <inheritdoc/>
    protected override IEnumerable<Segment> Render(RenderOptions options, int maxWidth) {
        if (PixelWidth < 0) {
            throw new InvalidOperationException("Pixel width must be greater than zero.");
        }

        IEnumerable<Segment> DoRender() {
            Cell[,] pixels = _cells;
            int width = Width;
            int height = Height;

            // Got a max width?
            if (MaxWidth != null) {
                height = (int)(height * ((float)MaxWidth.Value) / Width);
                width = MaxWidth.Value;
            }

            // Exceed the max width when we take pixel width into account?
            if (width * PixelWidth > maxWidth) {
                height = (int)(height * (maxWidth / (float)(width * PixelWidth)));
                width = maxWidth / PixelWidth;

                // If it's not possible to scale the canvas sufficiently, it's too small to render.
                if (height == 0) {
                    yield break;
                }
            }

            // Need to rescale the pixel buffer?
            if (Scale && (width != Width || height != Height)) {
                pixels = ScaleDown(width, height);
            }

            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    Cell cell = pixels[x, y];

                    // Transparent cell
                    if (cell.Foreground == null && cell.Background == null && cell.Glyph == '\0') {
                        yield return ImageSegment.Transparent(PixelWidth);
                        continue;
                    }

                    string content;
                    if (cell.Glyph != '\0') {
                        content = cell.Glyph.ToString();
                        if (PixelWidth > content.Length) content = content.PadRight(PixelWidth);
                    }
                    else {
                        content = new string(' ', PixelWidth);
                    }

                    // Treat Color.Default as absence so we don't emit default-bg/fg SGR codes.
                    Color? fg = cell.Foreground.HasValue && cell.Foreground.Value != Color.Default ? cell.Foreground : null;
                    Color? bg = cell.Background.HasValue && cell.Background.Value != Color.Default ? cell.Background : null;

                    var style = new Style(foreground: fg, background: bg);
                    yield return ImageSegment.Create(content, style);
                }

                yield return Segment.LineBreak;
            }
        }

        // Materialize the iterator and return segments.
        return DoRender().ToList();
    }

    private Cell[,] ScaleDown(int newWidth, int newHeight) {
        var buffer = new Cell[newWidth, newHeight];
        int xRatio = ((Width << 16) / newWidth) + 1;
        int yRatio = ((Height << 16) / newHeight) + 1;

        for (int i = 0; i < newHeight; i++) {
            for (int j = 0; j < newWidth; j++) {
                int srcX = (j * xRatio) >> 16;
                int srcY = (i * yRatio) >> 16;

                if (srcX < 0) srcX = 0;
                if (srcY < 0) srcY = 0;
                if (srcX >= Width) srcX = Width - 1;
                if (srcY >= Height) srcY = Height - 1;

                buffer[j, i] = _cells[srcX, srcY];
            }
        }

        return buffer;
    }
}
