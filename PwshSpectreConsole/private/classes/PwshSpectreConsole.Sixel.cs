
using System.Text;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.PixelFormats;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Processing.Processors.Quantization;

// inspiration from https://github.com/sxyazi/yazi/blob/main/yazi-adapter/src/sixel.rs (MIT)
// and from Shauns powershell POC.

// WT implementation
// https://github.com/microsoft/terminal/blob/main/src/terminal/adapter/SixelParser.cpp#L103-L178
// Sixel commands from WT source.
// '#'  DECGCI - Color Introducer
// '!'  DECGRI - Repeat Introducer
// '$'  DECGCR - Graphics Carriage Return
//  '-' DECGNL - Graphics Next Line
// '+'  Undocumented home command (VT240 only)
// '"'  DECGRA - Set Raster Attributes

namespace PwshSpectreConsole.Sixel
{
  public class Convert
  {
    private const string SixelStart = "\u001BP0;1;8q\"1;1";
    private const string SixelEnd = "\u001B\\";
    private const string SixelDECGNL = "-";
    private const string SixelDECGCR = "$";

    public static string ImgToSixel(string filename, int width, int maxColors)
    {
      using var image = Image.Load<Rgba32>(filename);
      int scaledHeight = (int)Math.Round((double)image.Height / image.Width * width);
      image.Mutate(ctx =>
      {
        ctx.Resize(width, scaledHeight, KnownResamplers.NearestNeighbor);
        QuantizerOptions quantizerOptions = new()
        {
          MaxColors = maxColors
        };
        ctx.Quantize(new OctreeQuantizer(quantizerOptions));
      });
      Dictionary<Rgba32, int> palette = [];
      int colorIndex = 1;
      MemoryStream buffer = new();
      StreamWriter writer = new(buffer, Encoding.UTF8);
      // enter sixel mode, set raster attributes (width, height)
      writer.Write($"{SixelStart};{image.Width};{image.Height}");
      // TODO: fix transparency..
      // writer.Write("#0;2;0;0;0");
      image.ProcessPixelRows(accessor =>
      {
        for (int y = 0; y < accessor.Height; y++)
        {
          Span<Rgba32> pixelRow = accessor.GetRowSpan(y);
          char c = (char)('?' + (1 << (y % 6)));
          int lastColor = -1;
          int repeatCounter = 0;
          foreach (ref Rgba32 pixel in pixelRow)
          {
            if (!palette.TryGetValue(pixel, out int value))
            {
              value = colorIndex++;
              palette[pixel] = value;
              int r = (int)Math.Round(pixel.R / 255.0 * 100);
              int g = (int)Math.Round(pixel.G / 255.0 * 100);
              int b = (int)Math.Round(pixel.B / 255.0 * 100);
              writer.Write($"#{value};2;{r};{g};{b}");
            }
            int colorId = pixel.A == 0 ? 0 : value;
            // we only add to the buffer once we see a new color.
            if (colorId == lastColor || repeatCounter == 0)
            {
              lastColor = colorId;
              repeatCounter++;
              continue;
            }
            if (repeatCounter > 1)
            {
              writer.Write($"#{lastColor}!{repeatCounter}{c}");
            }
            else
            {
              writer.Write($"#{lastColor}{c}");
            }
            lastColor = colorId;
            repeatCounter = 1;
          }
          // this is the last pixel in the row..
          if (repeatCounter > 1)
          {
            writer.Write($"#{lastColor}!{repeatCounter}{c}");
          }
          else
          {
            writer.Write($"#{lastColor}{c}");
          }
          // carriage return
          writer.Write(SixelDECGCR);
          if (y % 6 == 5)
          {
            // next line
            writer.Write(SixelDECGNL);
          }
        }
      });
      // exit sixel mode
      writer.Write(SixelEnd);
      writer.Flush();
      return Encoding.UTF8.GetString(buffer.ToArray());
    }
  }
}
