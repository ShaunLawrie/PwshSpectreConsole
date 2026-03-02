namespace PwshSpectreConsole.Render;
// Lightweight paragraph that accepts ReadOnlySpan<char> appends to avoid
// intermediate substring allocations during parsing. It implements the
// necessary Renderable interfaces so it can be used anywhere a Spectre
// Paragraph is used (tables, cells, etc.).
public sealed class SpanParagraph : Renderable, IHasJustification, IOverflowable {
    private readonly struct SpanSegment {
        public readonly ReadOnlyMemory<char> Text;
        public readonly Style Style;
        public readonly Link? Link;

        public SpanSegment(ReadOnlyMemory<char> text, Style style, Link? link) {
            Text = text;
            Style = style;
            Link = link;
        }
    }

    private readonly List<List<SpanSegment>> _lines;
    // Optional override to control single-line rendering without reflection.
    // If null, code falls back to reflection to detect `RenderOptions.SingleLine`.
    public bool? SingleLineOverride { get; set; }

    public Justify? Justification { get; set; }
    public Overflow? Overflow { get; set; }

    public SpanParagraph() {
        _lines = [[]];
    }

    public SpanParagraph Append(ReadOnlySpan<char> text, Style? style = null, Link? link = null) {
        if (text.IsEmpty) return this;
        Style s = style ?? Style.Plain;

        int idx = 0;
        while (idx < text.Length) {
            int nl = text[idx..].IndexOf('\n');
            if (nl < 0) nl = text.Length - idx;

            ReadOnlySpan<char> part = text.Slice(idx, nl);
            if (part.Length > 0) {
                _lines[^1].Add(new SpanSegment(part.ToArray(), s, link));
            }

            idx += nl;
            if (idx < text.Length && text[idx] == '\n') {
                // start new line
                _lines.Add([]);
                idx++; // skip newline
            }
        }

        return this;
    }

    public SpanParagraph Append(string text, Style? style = null)
        => Append(text.AsSpan(), style);

    protected override Measurement Measure(RenderOptions options, int maxWidth) {
        if (_lines.Count == 0) return new Measurement(0, 0);

        int min = 0, max = 0;
        foreach (List<SpanSegment> line in _lines) {
            int lineCells = 0;
            foreach (SpanSegment segment in line) {
                // approximate by character count; accurate measurement requires Segment.CellCount
                lineCells += segment.Text.Length;
            }
            min = Math.Max(min, lineCells);
            max = Math.Max(max, lineCells);
        }

        return new Measurement(min, Math.Min(max, maxWidth));
    }

    protected override IEnumerable<Segment> Render(RenderOptions options, int maxWidth) {
        var linesOut = new List<SegmentLine>();
        foreach (List<SpanSegment> line in _lines) {
            var segLine = new SegmentLine();
            foreach (SpanSegment segment in line) {
                // Convert slice to string now (deferred allocation)
                segLine.Add(new Segment(segment.Text.ToString(), segment.Style));
            }
            linesOut.Add(segLine);
        }

        // Use explicit override only. Do not use reflection for `SingleLine` detection
        // to avoid runtime overhead and version-dependent behavior. Callers that
        // need single-line rendering should set `SingleLineOverride = true` on the
        // SpanParagraph instance before it is rendered (table adapters do this).
        bool singleLine = SingleLineOverride.HasValue && SingleLineOverride.Value;

        return singleLine
            ? linesOut.Count > 0 ? linesOut[0].Where(s => !s.IsLineBreak) : []
            : new SegmentLineEnumerator(linesOut);
    }

    // Convert this SpanParagraph into a Spectre Paragraph by materializing
    // the deferred slices into strings. This allows reuse of the low-allocation
    // parsing path while producing a `Paragraph` for callers that need it.
    public Paragraph ToParagraph() {
        var paragraph = new Paragraph();
        for (int li = 0; li < _lines.Count; li++) {
            foreach (SpanSegment segment in _lines[li]) {
                paragraph.Append(segment.Text.ToString(), segment.Style, segment.Link);
            }
            if (li < _lines.Count - 1) paragraph.Append("\n");
        }
        return paragraph;
    }
}
