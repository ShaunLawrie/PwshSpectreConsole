namespace PwshSpectreConsole.Render;

public static partial class CellRender {
    private static bool IsTransparent(Rgba32 pixel) => pixel.A == 0;
    private static bool IsTransparentAdv(Rgba32 pixel) {
        if (pixel.A == 0) return true;

        float luminance = ((0.299f * pixel.R) + (0.587f * pixel.G) + (0.114f * pixel.B)) / 255f;
        return pixel.A < 8 ||
                (pixel.A < 32 && luminance < 0.15f) ||
                (pixel.A < 64 && pixel.R < 12 && pixel.G < 12 && pixel.B < 12) ||
                (pixel.A < 128 && luminance < 0.05f) ||
                (pixel.A < 240 && luminance < 0.01f);
    }

    private static (byte R, byte G, byte B) BlendPixels(Rgba32 top, Rgba32 bottom) {
        // If pixel is fully transparent, return the background color
        if (IsTransparent(top) && IsTransparent(bottom)) {
            return (0, 0, 0);
        }

        float amount = top.A / 255f;

        byte r = (byte)((top.R * amount) + (bottom.R * (1 - amount)));
        byte g = (byte)((top.G * amount) + (bottom.G * (1 - amount)));
        byte b = (byte)((top.B * amount) + (bottom.B * (1 - amount)));

        return (r, g, b);
    }
    private static (byte R, byte G, byte B) CompositeOverBlack(Rgba32 src) {
        // If the source is considered transparent, emit (0,0,0) to indicate
        // a transparent half. Otherwise emit the raw RGB bytes.
        if (IsTransparent(src)) return (0, 0, 0);
        return (src.R, src.G, src.B);
    }

    private static (byte R, byte G, byte B) CompositeOver(Rgba32 src, Rgba32 dst) {
        // Composite src over dst taking both alpha channels into account.
        if (IsTransparent(src) && IsTransparent(dst)) return (0, 0, 0);

        float sa = src.A / 255f;
        float da = dst.A / 255f;

        // Resulting colour components (approximate, no premultiplied linear correction)
        float r = (src.R * sa) + (dst.R * da * (1 - sa));
        float g = (src.G * sa) + (dst.G * da * (1 - sa));
        float b = (src.B * sa) + (dst.B * da * (1 - sa));

        byte R = (byte)Math.Clamp((int)Math.Round(r), 0, 255);
        byte G = (byte)Math.Clamp((int)Math.Round(g), 0, 255);
        byte B = (byte)Math.Clamp((int)Math.Round(b), 0, 255);

        return (R, G, B);
    }
}
