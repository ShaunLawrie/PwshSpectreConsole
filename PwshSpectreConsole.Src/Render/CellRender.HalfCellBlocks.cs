namespace PwshSpectreConsole.Render;

public static partial class CellRender {
    internal static void RenderHalfCellblocks(Image<Rgba32> image, ref ImageCanvas canvas) {
        for (int y = 0; y < image.Height; y += 2) {
            int cy = y / 2;
            for (int x = 0; x < image.Width; x++) {
                Rgba32 top = image[x, y];
                Rgba32 bottom = y + 1 < image.Height ? image[x, y + 1] : new Rgba32(0, 0, 0, 0);

                bool topTransparent = IsTransparent(top);
                bool bottomTransparent = IsTransparent(bottom);

                if (topTransparent && bottomTransparent) {
                    // leave transparent
                    continue;
                }
                else if (topTransparent) {
                    canvas.SetCell(x, cy, Constants.LowerHalfBlock, new Color(bottom.R, bottom.G, bottom.B));
                }
                else if (bottomTransparent) {
                    canvas.SetCell(x, cy, Constants.UpperHalfBlock, new Color(top.R, top.G, top.B));
                }
                else {
                    canvas.SetCell(x, cy, Constants.UpperHalfBlock, new Color(top.R, top.G, top.B), new Color(bottom.R, bottom.G, bottom.B));
                }
            }
        }
    }
}
