namespace PwshSpectreConsole;

public static class VTParser {
    private const char ESC = '\x1B';
    private const char CSI_START = '[';
    private const char OSC_START = ']';
    private const char SGR_END = 'm';
    /// <summary>
    /// Parse input into a low-allocation <see cref="SpanParagraph"/>.
    ///
    /// Notes and edge cases:
    /// - The parser operates on spans to avoid transient allocations.
    /// - Numeric parameters are accumulated into a single <see cref="byte"/> and
    ///   saturated at 255 to avoid overflow while keeping math cheap.
    /// - Parameters are stored in a stack-allocated <c>Span&lt;byte&gt;</c> of length 16;
    ///   most SGR sequences use far fewer params. If more than 16 params are present
    ///   the excess are ignored (truncated) — this mirrors typical terminal behavior
    ///   and avoids heap allocations for pathological input.
    /// - Separators ';' and ':' are both supported: SGR uses ';' while OSC hyperlinks
    ///   may use ':' in some sequences; supporting both avoids malformed edge cases.
    /// - On encountering malformed escape sequences we advance by one character
    ///   (returning <c>start + 1</c>) rather than throwing. This keeps the parser
    ///   resilient to garbage input and allows the rest of the string to be parsed.
    /// </summary>
    public static SpanParagraph ToSpanParagraph(string input) {
        if (string.IsNullOrEmpty(input)) return new SpanParagraph();

        var paragraph = new SpanParagraph();
        ReadOnlySpan<char> span = input.AsSpan();
        var currentStyle = new StyleState();

        var vsb = new ValueStringBuilder(256);
        int i = 0;

        while (i < span.Length) {
            if (span[i] == ESC && i + 1 < span.Length) {
                if (span[i + 1] == CSI_START) {
                    // flush accumulated text
                    if (VsbLength(ref vsb) > 0) {
                        ReadOnlySpan<char> textSpan = vsb.AsSpan();
                        paragraph.Append(textSpan, currentStyle.HasAnyStyle ? currentStyle.ToSpectreStyle() : Style.Plain);
                        vsb.Clear();
                    }

                    int escapeEnd = ParseEscapeSequence(span, i, ref currentStyle);
                    if (escapeEnd > i) {
                        i = escapeEnd;
                    }
                    else {
                        // malformed sequence; advance one char to avoid infinite loop
                        i++;
                    }
                }
                else if (span[i + 1] == OSC_START) {
                    // flush accumulated text
                    if (VsbLength(ref vsb) > 0) {
                        ReadOnlySpan<char> textSpan = vsb.AsSpan();
                        paragraph.Append(textSpan, currentStyle.HasAnyStyle ? currentStyle.ToSpectreStyle() : Style.Plain);
                        vsb.Clear();
                    }
                    OscResult oscResult = ParseOscSequence(span, i, ref currentStyle);
                    if (oscResult.End > i) {
                        // If OSC returned a link text, append it with the current style
                        if (!string.IsNullOrEmpty(oscResult.LinkText)) paragraph.Append(oscResult.LinkText.AsSpan(), currentStyle.HasAnyStyle ? currentStyle.ToSpectreStyle() : Style.Plain);
                        i = oscResult.End;
                    }
                    else {
                        i++;
                    }
                }
                else {
                    i++;
                }
            }
            else {
                vsb.Append(span[i]);
                i++;
            }
        }

        if (VsbLength(ref vsb) > 0) {
            ReadOnlySpan<char> textSpan = vsb.AsSpan();
            paragraph.Append(textSpan, currentStyle.HasAnyStyle ? currentStyle.ToSpectreStyle() : Style.Plain);
        }

        return paragraph;
    }

    // helper to access the internal _pos via unsafe reflection-like approach isn't available here,
    // so we emulate a small helper that tries to avoid exposing internals: hack by appending and trimming not needed.
    private static int VsbLength(ref ValueStringBuilder vsb) => vsb.Length;
    private static int ParseEscapeSequence(ReadOnlySpan<char> span, int start, ref StyleState style) {
        int i = start + 2;
        const int MaxEscapeSequenceLength = 1024;
        Span<byte> parameters = stackalloc byte[16];
        int paramCount = 0;
        byte currentNumber = 0;
        bool hasNumber = false;
        for (int escapeLength = 0; i < span.Length && span[i] != SGR_END && escapeLength < MaxEscapeSequenceLength; escapeLength++) {
            if (IsDigit(span[i])) {
                int digit = span[i] - '0';
                if (currentNumber > 25) {
                    currentNumber = 255;
                }
                else {
                    int tmp = (currentNumber * 10) + digit; currentNumber = tmp > 255 ? (byte)255 : (byte)tmp;
                }
                hasNumber = true;
            }
            else if (span[i] is ';' or ':') {
                if (paramCount < parameters.Length) parameters[paramCount++] = (byte)(hasNumber ? currentNumber : 0);
                currentNumber = 0; hasNumber = false;
            }
            else {
                return start + 1;
            }

            i++;
        }

        if (i >= span.Length || span[i] != SGR_END) return start + 1;
        if (paramCount < parameters.Length) parameters[paramCount++] = (byte)(hasNumber ? currentNumber : 0);
        ApplySgrParameters(parameters[..paramCount], ref style);
        return i + 1;
    }

    private readonly struct OscResult {
        public readonly int End;
        public readonly string? LinkText;
        public OscResult(int end, string? linkText = null) { End = end; LinkText = linkText; }
    }

    private static OscResult ParseOscSequence(ReadOnlySpan<char> span, int start, ref StyleState style) {
        int i = start + 2; // Skip ESC]
        const int MaxOscLength = 32768;
        int oscLength = 0;

        // Check if this is OSC 8 (hyperlink)
        if (i < span.Length && span[i] == '8' && i + 1 < span.Length && span[i + 1] == ';') {
            i += 2; // Skip "8;"

            // Parse hyperlink sequence: ESC]8;params;url ESC\text ESC]8;; ESC\
            int urlEnd = -1;

            // Find the semicolon that separates params from URL
            while (i < span.Length && span[i] != ';' && oscLength < MaxOscLength) {
                i++;
                oscLength++;
            }

            if (i < span.Length && span[i] == ';') {
                i++; // Skip the semicolon
                oscLength++;
                int urlStart = i;

                // Find the end of the URL (look for ESC\)
                while (i < span.Length - 1 && oscLength < MaxOscLength) {
                    if (span[i] == ESC && span[i + 1] == '\\') {
                        urlEnd = i;
                        break;
                    }
                    i++;
                    oscLength++;
                }

                if (urlEnd > urlStart && urlEnd - urlStart < MaxOscLength) {
                    string url = span[urlStart..urlEnd].ToString();
                    i = urlEnd + 2; // Skip ESC\\

                    // Check if this is a link start (has URL) or link end (empty)
                    if (!string.IsNullOrEmpty(url)) {
                        // This is a link start - find the link text and end sequence
                        int linkTextStart = i;
                        int linkTextEnd = -1;

                        // Look for the closing OSC sequence: ESC]8;;ESC\
                        while (i < span.Length - 6 && oscLength < MaxOscLength)  // Need at least 6 chars for ESC]8;;ESC\\
                        {
                            if (span[i] == ESC && span[i + 1] == OSC_START &&
                                span[i + 2] == '8' && span[i + 3] == ';' &&
                                span[i + 4] == ';' && span[i + 5] == ESC &&
                                span[i + 6] == '\\') {
                                linkTextEnd = i;
                                break;
                            }
                            i++;
                            oscLength++;
                        }

                        if (linkTextEnd > linkTextStart) {
                            string linkText = span[linkTextStart..linkTextEnd].ToString();
                            style.Link = url;
                            return new OscResult(linkTextEnd + 7, linkText); // Skip ESC]8;;ESC\\
                        }
                    }
                    else {
                        // This is likely a link end sequence: ESC]8;;ESC\\
                        style.Link = null;
                        return new OscResult(i);
                    }
                }
            }
        }

        // If we can't parse the OSC sequence, skip to the next ESC\ or end of string
        while (i < span.Length - 1 && oscLength < MaxOscLength) {
            if (span[i] == ESC && span[i + 1] == '\\') {
                return new OscResult(i + 2);
            }
            i++;
            oscLength++;
        }

        return new OscResult(start + 1); // Failed to parse, advance by 1
    }

    internal struct StyleState {
        public Color? Foreground; public Color? Background; public Decoration Decoration; public string? Link;
        public readonly bool HasAnyStyle => Foreground.HasValue || Background.HasValue || Decoration is not Decoration.None || Link is not null;
        public void Reset() { Foreground = null; Background = null; Decoration = Decoration.None; Link = null; }
        public readonly Style ToSpectreStyle() => Link is null ? new(Foreground, Background, Decoration) : new(Foreground, Background, Decoration, Link);
    }

    private static void ApplySgrParameters(ReadOnlySpan<byte> parameters, ref StyleState style) {
        for (int i = 0; i < parameters.Length; i++) {
            int param = parameters[i];
            switch (param) {
                case 0: style.Reset(); break;
                case 1: style.Decoration |= Decoration.Bold; break;
                case 2: style.Decoration |= Decoration.Dim; break;
                case 3: style.Decoration |= Decoration.Italic; break;
                case 4: style.Decoration |= Decoration.Underline; break;
                case 5: style.Decoration |= Decoration.SlowBlink; break;
                case 6: style.Decoration |= Decoration.RapidBlink; break;
                case 7: style.Decoration |= Decoration.Invert; break;
                case 8: style.Decoration |= Decoration.Conceal; break;
                case 9: style.Decoration |= Decoration.Strikethrough; break;
                case 22: style.Decoration &= ~(Decoration.Bold | Decoration.Dim); break;
                case 23: style.Decoration &= ~Decoration.Italic; break;
                case 24: style.Decoration &= ~Decoration.Underline; break;
                case 25: style.Decoration &= ~(Decoration.SlowBlink | Decoration.RapidBlink); break;
                case 27: style.Decoration &= ~Decoration.Invert; break;
                case 28: style.Decoration &= ~Decoration.Conceal; break;
                case 29: style.Decoration &= ~Decoration.Strikethrough; break;
                case >= 30 and <= 37: style.Foreground = GetConsoleColor(param); break;
                case 38:
                    if (i + 1 < parameters.Length) {
                        int colorType = parameters[i + 1];
                        if (colorType == 2 && i + 4 < parameters.Length) { byte r = parameters[i + 2]; byte g = parameters[i + 3]; byte b = parameters[i + 4]; style.Foreground = new Color(r, g, b); i += 4; }
                        else if (colorType == 5 && i + 2 < parameters.Length) { byte colorIndex = parameters[i + 2]; style.Foreground = Get256Color(colorIndex); i += 2; }
                    }
                    break;
                case 39: style.Foreground = null; break;
                case >= 40 and <= 47: style.Background = GetConsoleColor(param); break;
                case 48:
                    if (i + 1 < parameters.Length) {
                        byte colorType = parameters[i + 1];
                        if (colorType == 2 && i + 4 < parameters.Length) { byte r = parameters[i + 2]; byte g = parameters[i + 3]; byte b = parameters[i + 4]; style.Background = new Color(r, g, b); i += 4; }
                        else if (colorType == 5 && i + 2 < parameters.Length) { byte colorIndex = parameters[i + 2]; style.Background = Get256Color(colorIndex); i += 2; }
                    }
                    break;
                case 49: style.Background = null; break;
                case >= 90 and <= 97: style.Foreground = GetConsoleColor(param); break;
                case >= 100 and <= 107: style.Background = GetConsoleColor(param); break;
                default: break;
            }
        }
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static Color GetConsoleColor(int code) => code switch {
        0 => Color.Black,
        1 => Color.Navy,
        2 => Color.Green,
        3 => Color.Teal,
        4 => Color.Maroon,
        5 => Color.Purple,
        6 => Color.Olive,
        7 => Color.Silver,
        8 => Color.Grey,
        9 => Color.Blue,
        10 => Color.Lime,
        11 => Color.Aqua,
        12 => Color.Red,
        13 => Color.Fuchsia,
        14 => Color.Yellow,
        15 => Color.White,
        30 => Color.Black,
        31 => Color.Maroon,
        32 => Color.Green,
        33 => Color.Olive,
        34 => Color.Navy,
        35 => Color.Purple,
        36 => Color.Teal,
        37 => Color.Silver,
        40 => Color.Black,
        41 => Color.Maroon,
        42 => Color.Green,
        43 => Color.Olive,
        44 => Color.Navy,
        45 => Color.Purple,
        46 => Color.Teal,
        47 => Color.Silver,
        90 => Color.Grey,
        91 => Color.Red,
        92 => Color.Lime,
        93 => Color.Yellow,
        94 => Color.Blue,
        95 => Color.Fuchsia,
        96 => Color.Aqua,
        97 => Color.White,
        100 => Color.Grey,
        101 => Color.Red,
        102 => Color.Lime,
        103 => Color.Yellow,
        104 => Color.Blue,
        105 => Color.Fuchsia,
        106 => Color.Aqua,
        107 => Color.White,
        _ => Color.Default
    };

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static Color Get256Color(byte index) {
        if (index < 16) {
            return index switch {
                0 => Color.Black,
                1 => Color.DarkRed,
                2 => Color.DarkGreen,
                3 => Color.Olive,
                4 => Color.DarkBlue,
                5 => Color.DarkMagenta,
                6 => Color.DarkCyan,
                7 => Color.Gray,
                8 => Color.Grey50,
                9 => Color.Red,
                10 => Color.Green,
                11 => Color.Yellow,
                12 => Color.Blue,
                13 => Color.Magenta,
                14 => Color.Cyan,
                15 => Color.White,
                _ => Color.Default
            };
        }

        if (index < 232) { int colorIndex = index - 16; int rIndex = colorIndex / 36; int gIndex = colorIndex % 36 / 6; int bIndex = colorIndex % 6; byte r = (byte)(rIndex * 51); byte g = (byte)(gIndex * 51); byte b = (byte)(bIndex * 51); return new Color(r, g, b); }
        byte gray = (byte)(8 + ((index - 232) * 10)); return new Color(gray, gray, gray);
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    private static bool IsDigit(char c) => (uint)(c - '0') <= 9;
}
