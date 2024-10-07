
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
// https://www.digiater.nl/openvms/decus/vax90b1/krypton-nasa/all-about-sixels.text
// https://github.com/hackerb9/vt340test/blob/main/docs/standards/graphicrenditions.md
namespace PwshSpectreConsole.Sixel;

public class Convert
{
  private static readonly StringBuilder SixelBuilder = new();
  private const char SixelEmpty = '?';
  private const char SixelDECGNL = '-';
  private const char SixelDECGCR = '$';
  private const string SixelStart = $"\u001BP0;1q\"1;1;";
  private const string SixelEnd = "\u001b\\";
  private const string TransparentColor = "#0;2;100;0;0";
  private static readonly ResizeOptions ResizeOptions = new()
  {
    Sampler = KnownResamplers.NearestNeighbor,
    PremultiplyAlpha = false
  };

  private static readonly QuantizerOptions QuantizerOptions = new()
  {
    MaxColors = 256
  };
  public static string ImgToSixel(string filename, int maxColors)
  {
    try
    {
      using var image = LoadImage(filename);
      // we always need to mutate the colors.. but maybe not always width.
      MutateColors(image, maxColors);
      RenderImage(image);
      return SixelBuilder.ToString();
    }
    finally
    {
      SixelBuilder.Clear();
    }
  }
  public static string ImgToSixel(string filename, int maxColors, int width)
  {
    try
    {
      using var image = LoadImage(filename);
      int scaledHeight = (int)Math.Round((double)image.Height / image.Width * width);
      // we always need to mutate the colors.. but maybe not always width.
      MutateSizeAndColors(image, width, scaledHeight, maxColors);
      RenderImage(image);
      return SixelBuilder.ToString();
    }
    finally
    {
      SixelBuilder.Clear();
    }
  }
  private static void MutateSizeAndColors(Image<Rgba32> image, int width, int scaledHeight, int maxColors)
  {
    image.Mutate(ctx =>
    {
      ResizeOptions.Size = new Size(width, scaledHeight);
      ctx.Resize(ResizeOptions);
      QuantizerOptions.MaxColors = maxColors;
      ctx.Quantize(new OctreeQuantizer(QuantizerOptions));
    });
  }
  private static void MutateColors(Image<Rgba32> image, int maxColors)
  {
    image.Mutate(ctx =>
    {
      QuantizerOptions.MaxColors = maxColors;
      ctx.Quantize(new OctreeQuantizer(QuantizerOptions));
    });
  }

  private static Image<Rgba32> LoadImage(string filename)
  {
    return Image.Load<Rgba32>(filename);
  }
  private static void RenderImage(Image<Rgba32> image)
  {
    Dictionary<Rgba32, int> palette = new();
    int colorCounter = 1;
    SixelBuilder.Append(SixelStart)
                .Append(image.Width)
                .Append(';')
                .Append(image.Height)
                .Append(TransparentColor);
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
          if (!palette.TryGetValue(pixel, out int colorIndex))
          {
            colorIndex = colorCounter++;
            palette[pixel] = colorIndex;
            AddColorToPalette(pixel, colorIndex);
          }

          int colorId = pixel.A == 0 ? 0 : colorIndex;

          if (colorId == lastColor || repeatCounter == 0)
          {
            lastColor = colorId;
            repeatCounter++;
            continue;
          }

          if (repeatCounter > 1)
          {
            AppendRepeatEntry(lastColor, repeatCounter, c);
          }
          else
          {
            AppendSixelEntry(lastColor, c);
          }

          lastColor = colorId;
          repeatCounter = 1;
        }

        if (repeatCounter > 1)
        {
          AppendRepeatEntry(lastColor, repeatCounter, c);
        }
        else
        {
          AppendSixelEntry(lastColor, c);
        }

        AppendCarriageReturn();
        if (y % 6 == 5)
        {
          AppendNextLine();
        }
      }
    });
    // Exit sixel mode
    SixelBuilder.Append(SixelEnd);
  }

  private static void AddColorToPalette(Rgba32 pixel, int colorIndex)
  {
    int r = (int)Math.Round(pixel.R / 255.0 * 100);
    int g = (int)Math.Round(pixel.G / 255.0 * 100);
    int b = (int)Math.Round(pixel.B / 255.0 * 100);

    SixelBuilder.Append('#')
                .Append(colorIndex)
                .Append(";2;")
                .Append(r)
                .Append(';')
                .Append(g)
                .Append(';')
                .Append(b);
  }

  private static void AppendRepeatEntry(int color, int repeatCounter, char e)
  {
    SixelBuilder.Append('#')
                .Append(color)
                .Append('!')
                .Append(repeatCounter)
                .Append(color != 0 ? e : SixelEmpty);
  }

  private static void AppendSixelEntry(int color, char e)
  {
    SixelBuilder.Append('#')
                .Append(color)
                .Append(color != 0 ? e : SixelEmpty);
  }

  private static void AppendCarriageReturn()
  {
    SixelBuilder.Append(SixelDECGCR);
  }

  private static void AppendNextLine()
  {
    SixelBuilder.Append(SixelDECGNL);
  }
}
