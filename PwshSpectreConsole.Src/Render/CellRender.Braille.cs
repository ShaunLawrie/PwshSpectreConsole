namespace PwshSpectreConsole.Render;

public static partial class CellRender {
    internal static void RenderBraille(Image<Rgba32> image, ref ImageCanvas canvas) {
        int width = image.Width;
        int height = image.Height;
        int cellRows = canvas.Height;
        int cellPixelWidth = Math.Max(1, width / Math.Max(1, canvas.Width));

        for (int row = 0; row < cellRows; row++) {
            for (int cx = 0; cx < canvas.Width; cx++) {
                int baseX = cx * cellPixelWidth;

                int dotBits = 0;
                int rSum = 0, gSum = 0, bSum = 0, sampleCount = 0;

                for (int dx = 0; dx < 2; dx++) {
                    int sampleOffsetX = (int)Math.Round((dx + 0.5) / 2.0 * cellPixelWidth);
                    for (int dy = 0; dy < 4; dy++) {
                        int sampleX = Math.Clamp(baseX + sampleOffsetX, 0, width - 1);
                        int sampleY = Math.Clamp((int)Math.Round((row + ((dy + 0.5) / 4.0)) * height / cellRows), 0, height - 1);
                        Rgba32 px = image[sampleX, sampleY];
                        bool on = !IsTransparent(px);
                        if (on) {
                            int dotIndex = dx == 0 ? (dy == 0 ? 0 : dy == 1 ? 1 : dy == 2 ? 2 : 6) : (dy == 0 ? 3 : dy == 1 ? 4 : dy == 2 ? 5 : 7);
                            dotBits |= 1 << dotIndex;
                            rSum += px.R; gSum += px.G; bSum += px.B;
                            sampleCount++;
                        }
                    }
                }

                if (dotBits == 0) {
                    continue;
                }

                byte R = (byte)(rSum / Math.Max(1, sampleCount));
                byte G = (byte)(gSum / Math.Max(1, sampleCount));
                byte B = (byte)(bSum / Math.Max(1, sampleCount));
                int codepoint = 0x2800 + dotBits;

                canvas.SetCell(cx, row, (char)codepoint, new Color(R, G, B));
            }
        }
    }
}
