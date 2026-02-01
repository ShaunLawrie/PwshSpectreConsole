
namespace PwshSpectreConsole.Render;
// Small local segment type for internal use and future extensions.
public readonly struct PwshSegment {
    public string Text { get; }
    public Style Style { get; }
    public PwshSegment(string text, Style style) { Text = text ?? string.Empty; Style = style; }
    public bool IsLineBreak => Text == "\n";
    public Segment ToSpectre() => new(Text, Style);
}
