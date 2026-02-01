namespace PwshSpectreConsole.Render;
// Line composed of PwshSegments. Provides helper to convert to Spectre SegmentLine.
public sealed class PwshSegmentLine {
    private readonly List<PwshSegment> _items = [];
    public void Add(PwshSegment seg) => _items.Add(seg);
    public IEnumerable<Segment> ToSpectreSegments() {
        foreach (PwshSegment s in _items) yield return s.ToSpectre();
    }
    public bool IsEmpty => _items.Count == 0;
}
