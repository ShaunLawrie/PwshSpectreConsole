namespace PwshSpectreConsole.Render;

/// <summary>
/// Wrapper around <see cref="TextPath"/> that overrides <see cref="ToString"/>
/// to produce a markup string. This allows PowerShell string interpolation
/// (e.g. <c>"hello $path"</c>) to embed the styled path as markup text.
/// </summary>
public sealed class SpectreTextPath : Renderable, IHasJustification {
    private readonly TextPath _inner;

    /// <summary>Gets or sets the root style.</summary>
    public Style? RootStyle {
        get => _inner.RootStyle;
        set => _inner.RootStyle = value;
    }

    /// <summary>Gets or sets the separator style.</summary>
    public Style? SeparatorStyle {
        get => _inner.SeparatorStyle;
        set => _inner.SeparatorStyle = value;
    }

    /// <summary>Gets or sets the stem style.</summary>
    public Style? StemStyle {
        get => _inner.StemStyle;
        set => _inner.StemStyle = value;
    }

    /// <summary>Gets or sets the leaf style.</summary>
    public Style? LeafStyle {
        get => _inner.LeafStyle;
        set => _inner.LeafStyle = value;
    }

    /// <summary>Gets or sets the alignment.</summary>
    public Justify? Justification {
        get => _inner.Justification;
        set => _inner.Justification = value;
    }

    /// <summary>
    /// Initializes a new instance of <see cref="SpectreTextPath"/> wrapping a new <see cref="TextPath"/>.
    /// </summary>
    /// <param name="path">The file system path to render.</param>
    public SpectreTextPath(string path) {
        _inner = new TextPath(path);
    }

    /// <inheritdoc/>
    protected override Measurement Measure(RenderOptions options, int maxWidth)
        => _inner.Measure(options, maxWidth);

    /// <inheritdoc/>
    protected override IEnumerable<Segment> Render(RenderOptions options, int maxWidth)
        => _inner.Render(options, maxWidth);

    /// <summary>
    /// Returns a markup-formatted string of this path, sized to the current console width.
    /// This is what PowerShell string interpolation will use.
    /// </summary>
    public override string ToString()
        => _inner.ToMarkupString(AnsiConsole.Console.Profile.Width);
}
