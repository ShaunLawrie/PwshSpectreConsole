namespace PwshSpectreConsole.Terminal;

/// <summary>
/// Sixel terminal compatibility helpers.
/// </summary>
public static class Compatibility {
    /// <summary>
    /// Memory-caches the result of the terminal supporting sixel graphics.
    /// </summary>
    private static bool? _terminalSupportsSixel;
    private static bool? _terminalSupportsSynchronizedOutput;

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
    /// query if the terminal supports synchronized output.
    /// Use CSI ? 2026 $ p to query the state of the (DEC) mode 2026.
    /// This works for any private mode number.
    /// If you get nothing back (DECRQM not implemented at all)
    /// or you get back a CSI ? 2026 ; 0 $ y
    /// 0 	Mode is not recognized 	not supported
    /// 1 	Set
    /// 2 	Reset
    /// 3 	Permanently set
    /// 4 	Permanently reset
    /// => [?2026;0$y
    /// See DECRQM (request) and DECRPM (response) for more details.
    /// </summary>
    public static bool TerminalSupportsSynchronizedOutput() {
        if (_terminalSupportsSynchronizedOutput.HasValue) {
            return _terminalSupportsSynchronizedOutput.Value;
        }

        string response = GetControlSequenceResponse(Constants.DECRQM2026);
        try {
            if (string.IsNullOrEmpty(response)) {
                _terminalSupportsSynchronizedOutput = false;
                return false;
            }

            // Expected response: ESC[?2026;<n>$y  where <n> is a number (0..4)
            int idx = response.IndexOf("?2026;", StringComparison.Ordinal);
            if (idx >= 0) {
                int start = idx + "?2026;".Length;
                int end = response.IndexOf('$', start);
                if (end < 0) {
                    // If no $ found, try to find a non-digit terminator or use rest of string
                    end = start;
                    while (end < response.Length && char.IsDigit(response[end])) end++;
                }

                if (end > start) {
                    string numberText = response[start..end];
                    if (int.TryParse(numberText, NumberStyles.Integer, CultureInfo.InvariantCulture, out int number)) {
                        // 0 = not recognized (not supported). 1..4 indicate supported states.
                        _terminalSupportsSynchronizedOutput = number != 0;
                        // Console.WriteLine($"Synchronized Output: received {number}");
                        return _terminalSupportsSynchronizedOutput.Value;
                    }
                }
            }

            // As a fallback, try to extract the last numeric token from the response
            for (int i = response.Length - 1; i >= 0; i--) {
                if (char.IsDigit(response[i])) {
                    int j = i;
                    while (j >= 0 && char.IsDigit(response[j])) j--;
                    string candidate = response.Substring(j + 1, i - j);
                    if (int.TryParse(candidate, NumberStyles.Integer, CultureInfo.InvariantCulture, out int fallbackNumber)) {
                        _terminalSupportsSynchronizedOutput = fallbackNumber != 0;
                        Console.WriteLine($"Synchronized Output fallback: received {fallbackNumber}");
                        return _terminalSupportsSynchronizedOutput.Value;
                    }
                    break;
                }
            }
        }
        catch {
            return false;
        }
        return false;
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
}
