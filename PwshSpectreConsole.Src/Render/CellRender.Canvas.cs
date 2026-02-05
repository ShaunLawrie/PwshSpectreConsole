namespace PwshSpectreConsole.Render;

public static partial class CellRender {
    ///<summary>
    /// Render Canvas (single cell color)
    /// similar to original spectre canvas
    /// but with color blending top and bottom pixel
    /// </summary>
    internal static void RenderCanvas(Image<Rgba32> image, ref ImageCanvas canvas) {
        for (int y = 0; y < image.Height; y += 2) {
            int cy = y / 2;
            for (int x = 0; x < image.Width; x++) {
                Rgba32 top = image[x, y];
                Rgba32 bottom = y + 1 < image.Height ? image[x, y + 1] : new Rgba32(0, 0, 0, 0);
                if (IsTransparent(top) && IsTransparent(bottom)) {
                    continue;
                }
                (byte R, byte G, byte B) = BlendPixels(top, bottom);
                canvas.SetCell(x, cy, Constants.FullBlock, new Color(R, G, B));
            }
        }
    }
}
