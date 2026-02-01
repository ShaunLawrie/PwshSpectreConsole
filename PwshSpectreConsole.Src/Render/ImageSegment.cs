namespace PwshSpectreConsole;

/// <summary>
/// Helper methods for creating and working with sixel-related segments.
/// </summary>
public static class ImageSegment {
    /// <summary>
    /// Gets a transparent segment.
    /// </summary>
    /// <param name="size">The size of the transparent segment.</param>
    /// <returns>A transparent segment.</returns>
    public static Segment Transparent(int size) => Segment.Padding(size);

    /// <summary>
    /// Creates a new segment with the specified text.
    /// </summary>
    public static Segment Create(string text) => new(text);

    /// <summary>
    /// Creates a new segment with the specified text and style.
    /// </summary>
    public static Segment Create(string text, Style style) => new(text, style);

    /// <summary>
    /// Wrapper around <see cref="Segment.SplitOverflow"/>.
    /// </summary>
    public static List<Segment> SplitOverflow(Segment segment, Overflow? overflow, int maxWidth)
        => Segment.SplitOverflow(segment, overflow, maxWidth);
}
