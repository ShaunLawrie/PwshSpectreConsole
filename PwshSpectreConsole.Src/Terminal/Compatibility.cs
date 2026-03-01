namespace PwshSpectreConsole.Terminal;

/// <summary>
/// Sixel terminal compatibility helpers.
/// </summary>
public static class Compatibility {
    /// <summary>
    /// Memory-caches the result of the terminal supporting sixel graphics.
    /// </summary>
    private static bool? _terminalSupportsSixel;
    /// <summary>
    /// Memory-caches the result of the terminal cell size, sending the control code is slow.
    /// </summary>
    private static CellSize? _cellSize;

    /// <summary>
    /// Get the cell size of the terminal in pixel-sixel size.
    /// The response to the command will look like [6;20;10t where the 20 is height and 10 is width.
    /// I think the 6 is the terminal class, which is not used here.
    /// </summary>
    /// <returns>The number of pixel sixels that will fit in a single character cell.</returns>
    public static CellSize GetCellSize() {
        if (_cellSize is not null) {
            return _cellSize;
        }
        string response = GetControlSequenceResponse("[16t");

        try {
            string[] parts = response.Split(';', 't');
            if (parts.Length >= 3) {
                int width = int.Parse(parts[2], NumberStyles.Number, CultureInfo.InvariantCulture);
                int height = int.Parse(parts[1], NumberStyles.Number, CultureInfo.InvariantCulture);

                // Validate the parsed values are reasonable
                if (IsValidCellSize(width, height)) {
                    _cellSize = new CellSize {
                        PixelWidth = width,
                        PixelHeight = height
                    };
                    return _cellSize;
                }
            }
        }
        catch {
            // Fall through to platform-specific fallback
        }

        // Platform-specific fallback values
        _cellSize = GetPlatformDefaultCellSize();
        return _cellSize;
    }

    /// <summary>
    /// Check if the terminal supports sixel graphics.
    /// This is done by sending the terminal a Device Attributes request.
    /// If the terminal responds with a response that contains ";4;" then it supports sixel graphics.
    /// https://vt100.net/docs/vt510-rm/DA1.html.
    /// </summary>
    /// <returns>True if the terminal supports sixel graphics, false otherwise.</returns>
    public static bool TerminalSupportsSixel() {
        if (_terminalSupportsSixel.HasValue) {
            return _terminalSupportsSixel.Value;
        }

        string response = GetControlSequenceResponse(Constants.DA1);
        _terminalSupportsSixel = response.Contains(";4;") || response.Contains(";4c");
        return _terminalSupportsSixel.Value;
    }

    /// <summary>
    /// Send a control sequence to the terminal and read back the response from STDIN.
    /// </summary>
    /// <param name="controlSequence">The control sequence to send to the terminal.</param>
    /// <returns>The response from the terminal.</returns>
    public static string GetControlSequenceResponse(string controlSequence) {
        if (Console.IsOutputRedirected || Console.IsInputRedirected) {
            return string.Empty;
        }

        const int timeoutMs = 500;
        const int maxRetries = 3;

        for (int retry = 0; retry < maxRetries; retry++) {
            try {
                var response = new StringBuilder();

                // Send the control sequence
                Console.Write($"{Constants.ESC}{controlSequence}");
                var stopwatch = Stopwatch.StartNew();

                while (stopwatch.ElapsedMilliseconds < timeoutMs) {
                    if (!Console.KeyAvailable) {
                        Thread.Sleep(1);
                        continue;
                    }

                    ConsoleKeyInfo keyInfo = Console.ReadKey(true);
                    char key = keyInfo.KeyChar;
                    response.Append(key);

                    // Check if we have a complete response
                    if (IsCompleteResponse(response)) {
                        return response.ToString();
                    }
                }

                // If we got a partial response, return it
                if (response.Length > 0) {
                    return response.ToString();
                }
            }
            catch (Exception) {
                if (retry == maxRetries - 1) {
                    return string.Empty;
                }
            }
        }

        return string.Empty;
    }
    /// <summary>
    /// Check for complete terminal responses
    /// </summary>
    private static bool IsCompleteResponse(StringBuilder response) {
        int length = response.Length;
        if (length < 2) return false;

        // Look for common terminal response endings
        char lastChar = response[length - 1];

        // Most VT terminal responses end with specific letters
        switch (lastChar) {
            case 'c': // Device Attributes (ESC[...c)
            case 'R': // Cursor Position Report (ESC[row;columnR)
            case 't': // Window manipulation (ESC[...t)
            case 'n': // Device Status Report (ESC[...n)
            case 'y': // DECRPM response (ESC[?...y)
                      // Make sure it's actually a CSI sequence (ESC[)
                return length >= 3 && response[0] == '\x1b' && response[1] == '[';

            case '\\': // String Terminator (ESC\)
                return length >= 2 && response[length - 2] == '\x1b';

            case (char)7: // BEL character
                return true;

            default:
                // Check for Kitty graphics protocol: ends with ";OK" followed by ST and then another response
                if (length >= 7) // Minimum for ";OK" + ESC\ + ESC[...c
                {
                    // Look for ";OK" pattern
                    bool hasOK = false;
                    for (int i = 0; i <= length - 3; i++) {
                        if (response[i] == ';' && i + 2 < length &&
                            response[i + 1] == 'O' && response[i + 2] == 'K') {
                            hasOK = true;
                            break;
                        }
                    }

                    if (hasOK) {
                        // Look for ESC\ (String Terminator)
                        int stIndex = -1;
                        for (int i = 0; i < length - 1; i++) {
                            if (response[i] == '\x1b' && response[i + 1] == '\\') {
                                stIndex = i;
                                break;
                            }
                        }

                        if (stIndex >= 0 && stIndex + 2 < length) {
                            // Check if there's a complete response after the ST
                            int afterSTStart = stIndex + 2;
                            int afterSTLength = length - afterSTStart;
                            if (afterSTLength >= 3 &&
                                response[afterSTStart] == '\x1b' &&
                                response[afterSTStart + 1] == '[') {
                                char afterSTLast = response[length - 1];
                                return afterSTLast is 'c' or
                                        'R' or
                                        't' or
                                        'n' or
                                        'y';
                            }
                        }
                    }
                }
                return false;
        }
    }
    /// <summary>
    /// Minimal validation: only ensures positive integer values.
    /// Terminal-reported cell sizes are treated as ground truth.
    /// </summary>
    private static bool IsValidCellSize(int width, int height)
        => width > 0 && height > 0;
    /// <summary>
    /// Returns platform-specific default cell size as fallback.
    /// </summary>
    private static CellSize GetPlatformDefaultCellSize() {
        // Common terminal default sizes by platform
        // macOS terminals (especially with Retina) often use 10x20
        // Windows Terminal: 10x20
        // Linux varies: 8x16 to 10x20

        // expand this in the future.

        return new CellSize {
            PixelWidth = 10,
            PixelHeight = 20
        };
    }

    /// <summary>
    /// Gets the terminal height in cells. Returns 0 if the height cannot be determined.
    /// </summary>
    /// <returns>The terminal height in cells, or 0 if unavailable.</returns>
    public static int GetTerminalHeight() {
        try {
            if (!Console.IsOutputRedirected) {
                return Console.WindowHeight;
            }
        }
        catch {
            // Terminal height is unavailable (e.g. no console attached).
        }
        return 0;
    }
}
