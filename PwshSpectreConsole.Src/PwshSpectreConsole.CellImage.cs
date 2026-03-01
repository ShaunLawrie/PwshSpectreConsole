namespace PwshSpectreConsole;

/// <summary>
/// Represents a renderable image in Cell blocks.
/// </summary>
/// <remarks>
/// Initializes a new instance of the <see cref="CellImage"/> class.
/// </remarks>
/// <param name="filename">The image filename.</param>
/// <param name="animationDisabled">Whether the image should have animation disabled.</param>
public sealed class CellImage : Renderable {
    private static readonly IResampler _defaultResampler = KnownResamplers.Bicubic;

    /// <summary>
    /// Gets the image width in pixels.
    /// </summary>
    public int Width => Image.Width;
    /// <summary>
    /// Gets the image height in pixels.
    /// </summary>
    public int Height => Image.Height;

    /// <summary>
    /// Gets or sets the render width of the canvas in terminal cells.
    /// </summary>
    public int? MaxWidth { get; set; }

    /// <summary>
    /// Gets the render width of the canvas. This is hard coded to 1 for sixel images.
    /// </summary>
    public int PixelWidth { get; } = 1;

    /// <summary>
    /// Gets a value indicating whether the image should be animated.
    /// </summary>
    public bool AnimationDisabled { get; init; }

    public IResampler? Resampler { get; set; }

    /// <summary>
    /// Gets or sets the current frame of the image.
    /// </summary>
    public int FrameToRender {
        get => _frameToRender;
        set {
            if (value < 0) {
                throw new InvalidOperationException("Frame to render must be greater than zero.");
            }

            if (value >= Image.Frames.Count) {
                throw new InvalidOperationException("Frame to render must be less than the total number of frames in the image.");
            }

            _frameToRender = value;
        }
    }

    internal Image<Rgba32> Image { get; private set; }
    private readonly Dictionary<(int CanvasWidth, int CanvasHeight, ImageTypes Mode), ImageCanvas> _cachedBlocks = [];
    private int _frameToRender;
    internal ImageTypes _protocol;
    public CellImage(string filename) {
        AnimationDisabled = false;
        _protocol = ImageTypes.Blocks;
        Image = SixImage.Load<Rgba32>(filename);
    }

    public CellImage(string filename, ImageTypes? protocol, bool animationDisabled = false) {
        AnimationDisabled = animationDisabled;
        _protocol = protocol ?? ImageTypes.Blocks;
        Image = SixImage.Load<Rgba32>(filename);
    }

    /// <inheritdoc/>
    protected override Measurement Measure(RenderOptions options, int maxWidth) {
        int pixelWidth = options.Unicode ? 1 : 2;
        int width = MaxWidth ?? Width;
        return maxWidth < width * pixelWidth ? new Measurement(maxWidth, maxWidth) : new Measurement(width * pixelWidth, width * pixelWidth);
    }

    protected override IEnumerable<Segment> Render(RenderOptions options, int maxWidth) {
        Image<Rgba32> image = Image;

        // Determine effective mode (constructor may have set _protocol)
        ImageTypes mode = _protocol;

        // pixels per cell mapping for each mode
        int pixelsPerCellX;
        int pixelsPerCellY;
        if (mode is ImageTypes.Braille) {
            pixelsPerCellX = 2;
            pixelsPerCellY = 4;
        }
        else {
            pixelsPerCellX = 1;
            pixelsPerCellY = 2;
        }

        int terminalPixelWidth = options.Unicode ? 1 : 2;
        int maxAvailableCells = Math.Max(1, maxWidth / terminalPixelWidth);

        // Compute desired canvas width in terminal cells.
        int desiredCellsWidth;
        if (MaxWidth != null) {
            desiredCellsWidth = Math.Min(MaxWidth.Value, maxAvailableCells);
        }
        else {
            // natural size in cells based on the source image and mode
            desiredCellsWidth = Math.Min(Math.Max(1, Image.Width / pixelsPerCellX), maxAvailableCells);
        }

        // Determine canvas cell height from image aspect and requested cell width.
        int canvasWidth = Math.Max(1, desiredCellsWidth);
        int canvasHeight = Math.Max(1, (int)Math.Round(Image.Height / (double)Image.Width * canvasWidth * (pixelsPerCellX / (double)pixelsPerCellY)));

        // Compute target image pixel dimensions that are exact multiples of per-cell pixels.
        int targetImagePixelWidth = Math.Max(1, canvasWidth * pixelsPerCellX);
        int targetImagePixelHeight = Math.Max(1, canvasHeight * pixelsPerCellY);

        // Resize a working copy when needed
        if (targetImagePixelWidth != Image.Width || targetImagePixelHeight != Image.Height) {
            IResampler resampler = Resampler ?? _defaultResampler;
            image = image.Clone(i => i.Resize(targetImagePixelWidth, targetImagePixelHeight, resampler));
        }

        (int canvasWidth, int canvasHeight, ImageTypes mode) cacheKey = (canvasWidth, canvasHeight, mode);
        if (!_cachedBlocks.TryGetValue(cacheKey, out ImageCanvas? canvas)) {
            canvas = new ImageCanvas(canvasWidth, canvasHeight) {
                Scale = false,
                PixelWidth = 1,
            };

            switch (mode) {
                case ImageTypes.Sixel:
                    // no-op sixel should never end up here.
                    break;

                case ImageTypes.Braille:
                    CellRender.RenderBraille(image, ref canvas);
                    break;
                case ImageTypes.Canvas:
                    CellRender.RenderCanvas(image, ref canvas);
                    break;
                case ImageTypes.Auto:
                case ImageTypes.Blocks:
                default:
                    CellRender.RenderBlocks(image, ref canvas);
                    break;
            }

            _cachedBlocks[cacheKey] = canvas;
        }

        return ((IRenderable)canvas).Render(options, maxWidth);
    }
}
