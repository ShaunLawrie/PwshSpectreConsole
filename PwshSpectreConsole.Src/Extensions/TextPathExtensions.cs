namespace PwshSpectreConsole.Extensions;

public static class TextPathExtensions {
    /// <summary>
    /// Converts a <see cref="TextPath"/> to a markup string that can be embedded in other markup content.
    /// </summary>
    /// <param name="textPath">The TextPath to convert.</param>
    /// <param name="maxWidth">The maximum width available for rendering. Paths longer than this will be truncated.</param>
    /// <returns>A markup-formatted string representing the styled path.</returns>
    public static string ToMarkupString(this TextPath textPath, int maxWidth) {
        Capabilities capabilities = AnsiConsole.Console.Profile.Capabilities;
        var size = new Spectre.Console.Size(maxWidth, 1);
        var options = new RenderOptions(capabilities, size);

        IEnumerable<Segment> segments = textPath.Render(options, maxWidth);

        var sb = new StringBuilder();
        foreach (Segment segment in segments) {
            if (segment.IsLineBreak || segment.IsControlCode) {
                continue;
            }

            string text = segment.Text;
            if (string.IsNullOrEmpty(text)) {
                continue;
            }

            string escaped = Markup.Escape(text);
            string styleMarkup = segment.Style.ToMarkup();
            _ = string.IsNullOrEmpty(styleMarkup)
                ? sb.Append(escaped)
                : sb.Append('[').Append(styleMarkup).Append(']')
                  .Append(escaped)
                  .Append("[/]");
        }

        return sb.ToString().TrimEnd();
    }

    /// <summary>
    /// Converts a <see cref="TextPath"/> to <see cref="Markup"/> so it can be embedded in markup strings
    /// without needing to pipe through Out-SpectreHost.
    /// </summary>
    /// <param name="textPath">The TextPath to convert.</param>
    /// <param name="maxWidth">The maximum width available for rendering. Paths longer than this will be truncated.</param>
    /// <returns>A <see cref="Markup"/> instance representing the styled path.</returns>
    public static Markup ToMarkup(this TextPath textPath, int maxWidth)
        => new(textPath.ToMarkupString(maxWidth));
}
