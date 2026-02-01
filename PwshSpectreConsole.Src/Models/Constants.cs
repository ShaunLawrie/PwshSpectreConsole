namespace PwshSpectreConsole;

/// <summary>
/// Sixel terminal compatibility helpers.
/// </summary>
internal static class Constants {
    /// <summary>
    /// The character to use when entering a terminal escape code sequence.
    /// </summary>
    public const char ESC = '\u001b';

    /// <summary>
    /// The character to indicate the start of a sixel color palette entry or to switch to a new color.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.3.
    /// </summary>
    public const char SIXELCOLOR = '#';

    /// <summary>
    /// The character to use when a sixel is empty/transparent.
    /// ? (hex 3F) represents the binary value 000000.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.2.1.
    /// </summary>
    public const char SIXELEMPTY = '?';

    /// <summary>
    /// The character to use when entering a repeated sequence of a color in a sixel.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.1.
    /// </summary>
    public const char SIXELREPEAT = '!';

    /// <summary>
    /// The character to use when moving to the next line in a sixel.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.5.
    /// </summary>
    public const char SIXELDECGNL = '-';

    /// <summary>
    /// The character to use when going back to the start of the current line in a sixel to write more data over it.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.4.
    /// </summary>
    public const char SIXELDECGCR = '$';

    /// <summary>
    /// The start of a sixel sequence.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.2.1.
    /// </summary>
    public static readonly string SIXELSTART = $"{ESC}P0;1q";

    /// <summary>
    /// The raster settings for setting the sixel pixel ratio to 1:1 so images are square when rendered instead of the 2:1 double height default.
    /// https://vt100.net/docs/vt3xx-gp/chapter14.html#S14.3.2.
    /// </summary>
    public const string SIXELRASTERATTRIBUTES = "\"1;1;";

    /// <summary>
    /// The end of a sixel sequence.
    /// </summary>
    public static readonly string SIXELEND = $"{ESC}\\";

    /// <summary>
    /// The transparent color for the sixel, this is black but the sixel should be transparent so this is not visible.
    /// </summary>
    public const string SIXELTRANSPARENTCOLOR = "#0;2;0;0;0";

    /// <summary>
    /// vt reset
    /// </summary>
    public static readonly string Reset = $"{ESC}[0m";

    /// <summary>
    /// lower half block character
    /// ▄
    /// this allows you to color the top and bottom of a cell.
    /// foreground colors the lower block and background colors the space above the block in the same cell.
    /// </summary>
    public const char LowerHalfBlock = '\u2584';
    /// <summary>
    /// upper half block character
    /// ▀
    /// this allows you to color the top and bottom of a cell.
    /// foreground colors the upper block and background colors the space below the block in the same cell.
    /// </summary>

    public const char UpperHalfBlock = '\u2580';
    /// <summary>
    /// full block character █ (U+2588)
    /// </summary>
    public const char FullBlock = '\u2588';
    /// <summary>
    /// left half block ▌ (U+258C)
    /// </summary>
    public const char LeftHalfBlock = '\u258C';
    /// <summary>
    /// right half block ▐ (U+2590)
    /// </summary>
    public const char RightHalfBlock = '\u2590';
    /// <summary>
    /// braille blank (U+2800)
    /// </summary>
    public const char BrailleBlank = '\u2800';
    /// <summary>
    /// explicit space char for clarity
    /// </summary>
    public const char Space = ' ';
    /// <summary>
    /// background color escape sequence
    /// </summary>
    public static readonly string VTBG = "[48;2;";

    /// <summary>
    /// foreground color escape sequence
    /// </summary>
    public static readonly string VTFG = "[38;2;";
    public static readonly string DECRQM2026 = "[?2026$p";
    public static readonly string DA1 = "[c";
}
