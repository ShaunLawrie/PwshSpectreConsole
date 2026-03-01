using Size = SixLabors.ImageSharp.Size;

namespace PwshSpectreConsole.Render;

/// <summary>
/// Contains methods for converting an image to a Sixel format.
/// </summary>
public static partial class SixelRender {
    /// <summary>
    /// Converts an image to a Sixel object.
    /// This uses a copy of the c# sixel codec from @trackd and @ShaunLawrie in https://github.com/trackd/Sixel.
    /// </summary>
    /// <param name="image">The image to convert.</param>
    /// <param name="cellWidth">The width of the cell in terminal cells.</param>
    /// <param name="disableAnimation">Whether to disable animation for the image and only load the first frame.</param>
    /// <returns>The Sixel object.</returns>
    public static Sixel ImageToSixel(Image<Rgba32> image, int cellWidth, bool disableAnimation = false) {
        // We're going to resize the image when it's rendered, so use a copy to leave the original untouched.
        Image<Rgba32> imageClone = image.Clone();

        // Convert to pixel sizes.
        int pixelWidth = cellWidth * Compatibility.GetCellSize().PixelWidth;
        int pixelHeight = (int)Math.Round((double)imageClone.Height / imageClone.Width * pixelWidth);

        imageClone.Mutate(ctx => {
            // Resize the image to the target size
            ctx.Resize(new ResizeOptions() {
                Sampler = KnownResamplers.Bicubic,
                Size = new Size(pixelWidth, pixelHeight),
                PremultiplyAlpha = false,
            });

            // Sixel supports 256 colors max
            ctx.Quantize(new OctreeQuantizer(new() {
                MaxColors = 256,
            }));
        });

        int cellPixelHeight = Compatibility.GetCellSize().PixelHeight;
        int cellHeight = (int)Math.Ceiling((double)pixelHeight / cellPixelHeight);
        var sixelStrings = new List<string>();

        for (int i = 0; i < imageClone.Frames.Count; i++) {
            sixelStrings.Add(
                FrameToSixelString(
                    imageClone.Frames[i],
                    cellHeight,
                    cellPixelHeight));

            if (disableAnimation) {
                break;
            }
        }

        return new Sixel(
            pixelWidth,
            pixelHeight,
            cellHeight,
            cellWidth,
            [.. sixelStrings]
        );
    }

    /// <summary>
    /// Converts an image frame to a Sixel string.
    /// </summary>
    /// <param name="frame">The image frame to convert.</param>
    /// <param name="cellHeight">The height of the cell in terminal cells.</param>
    /// <param name="cellPixelHeight">The height of in individual cell in pixels.</param>
    /// <returns>The Sixel string.</returns>
    private static string FrameToSixelString(ImageFrame<Rgba32> frame, int cellHeight, int cellPixelHeight) {
        var sixelBuilder = new StringBuilder();
        var palette = new Dictionary<Rgba32, int>();
        int colorCounter = 1;
        int y = 0;
        sixelBuilder.StartSixel(frame.Width, cellHeight * cellPixelHeight);
        frame.ProcessPixelRows(accessor => {
            for (y = 0; y < accessor.Height; y++) {
                Span<Rgba32> pixelRow = accessor.GetRowSpan(y);

                // The value of 1 left-shifted by the remainder of the current row divided by 6 gives the correct sixel character offset from the empty sixel char for each row.
                // See the description of s...s for more detail on the sixel format https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.2.1
                char c = (char)(Constants.SIXELEMPTY + (1 << (y % 6)));
                int lastColor = -1;
                int repeatCounter = 0;

                foreach (ref Rgba32 pixel in pixelRow) {
                    // The colors can be added to the palette and interleaved with the sixel data so long as the color is defined before it is used.
                    if (!palette.TryGetValue(pixel, out int colorIndex)) {
                        colorIndex = colorCounter++;
                        palette[pixel] = colorIndex;
                        sixelBuilder.AddColorToPalette(pixel, colorIndex);
                    }

                    // Transparency is a special color index of 0 that exists in our sixel palette.
                    int colorId = pixel.A == 0 ? 0 : colorIndex;

                    // Sixel data will use a repeat entry if the color is the same as the last one.
                    // https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.1
                    if (colorId == lastColor || repeatCounter == 0) {
                        // If the color was repeated go to the next loop iteration to check the next pixel.
                        lastColor = colorId;
                        repeatCounter++;
                        continue;
                    }

                    // Every time the color is not repeated the previous color is written to the string.
                    sixelBuilder.AppendSixel(lastColor, repeatCounter, c);

                    // Remember the current color and reset the repeat counter.
                    lastColor = colorId;
                    repeatCounter = 1;
                }

                // Write the last color and repeat counter to the string for the current row.
                sixelBuilder.AppendSixel(lastColor, repeatCounter, c);

                // Add a carriage return at the end of each row and a new line every 6 pixel rows.
                sixelBuilder.AppendCarriageReturn();
                if (y % 6 == 5) {
                    sixelBuilder.AppendNextLine();
                }
            }

            // Padding to ensure the cursor finishes below the image not halfway through the rendered pixels.
            for (int padding = y; padding <= (cellHeight * cellPixelHeight); padding++) {
                if (padding % 6 == 5) {
                    sixelBuilder.AppendNextLine();
                }
            }

            // And a final newline to position the cursor under the image.
            sixelBuilder.AppendNextLine();
        });

        sixelBuilder.AppendExitSixel();

        return sixelBuilder.ToString();
    }

    /// <summary>
    /// Adds a color to the sixel palette.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    /// <param name="pixel">The pixel to add to the palette.</param>
    /// <param name="colorIndex">The index of the color in the palette.</param>
    private static void AddColorToPalette(this StringBuilder sixelBuilder, Rgba32 pixel, int colorIndex) {
        // rgb 0-255 needs to be translated to 0-100 for sixel.
        (int r, int g, int b) = (
            pixel.R * 100 / 255,
            pixel.G * 100 / 255,
            pixel.B * 100 / 255
        );

        sixelBuilder.Append(Constants.SIXELCOLOR)
                    .Append(colorIndex)
                    .Append(";2;")
                    .Append(r)
                    .Append(';')
                    .Append(g)
                    .Append(';')
                    .Append(b);
    }

    /// <summary>
    /// Writes a repeated sixel entry to the string builder.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    /// <param name="colorIndex">The index of the color in the palette.</param>
    /// <param name="repeatCounter">The number of times the color is repeated.</param>
    /// <param name="sixel">The sixel character to write.</param>
    private static void AppendSixel(this StringBuilder sixelBuilder, int colorIndex, int repeatCounter, char sixel) {
        if (colorIndex == 0) {
            // Transparent pixels are a special case and are always 0 in the palette.
            sixel = Constants.SIXELEMPTY;
        }
        if (repeatCounter <= 1) {
            // single entry
            sixelBuilder
            .Append(Constants.SIXELCOLOR)
            .Append(colorIndex)
            .Append(sixel);
        }
        else {
            // add repeats
            sixelBuilder
            .Append(Constants.SIXELCOLOR)
            .Append(colorIndex)
            .Append(Constants.SIXELREPEAT)
            .Append(repeatCounter)
            .Append(sixel);
        }
    }

    /// <summary>
    /// Writes the Sixel carriage return sequence to the string builder.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    private static void AppendCarriageReturn(this StringBuilder sixelBuilder)
        => sixelBuilder.Append(Constants.SIXELDECGCR);

    /// <summary>
    /// Writes the Sixel next line sequence to the string builder.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    private static void AppendNextLine(this StringBuilder sixelBuilder)
        => sixelBuilder.Append(Constants.SIXELDECGNL);

    /// <summary>
    /// Writes the Sixel exit sequence to the string builder.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    private static void AppendExitSixel(this StringBuilder sixelBuilder)
        => sixelBuilder.Append(Constants.SIXELEND);

    /// <summary>
    /// Writes the Sixel start sequence to the string builder.
    /// </summary>
    /// <param name="sixelBuilder">The string builder to write to.</param>
    /// <param name="width">The width of the image in pixels.</param>
    /// <param name="height">The height of the image in pixels.</param>
    private static void StartSixel(this StringBuilder sixelBuilder, int width, int height) {
        sixelBuilder
        .Append(Constants.SIXELSTART)
        .Append(Constants.SIXELRASTERATTRIBUTES)
        .Append(width)
        .Append(';')
        .Append(height)
        .Append(Constants.SIXELTRANSPARENTCOLOR);
    }
}
