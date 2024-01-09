using System;
using System.Collections.Generic;
using System.Management.Automation;

namespace PwshSpectreConsole.VTCodes
{
    public class VT
    {
        // objects of this class are returned by the Parser
        public class VtCode
        {
            public object Value { get; set; } // color, decoration, etc.
            public string Type { get; set; } // 4bit, 8bit, 24bit, decoration
            public string Position { get; set; } // foreground, background
            public int Placement { get; set; } // placement in the string
        }
        public class RGB
        {
            public int Red { get; set; }
            public int Green { get; set; }
            public int Blue { get; set; }
            public override string ToString()
            {
                return $"RGB({Red},{Green},{Blue})";
            }

        }
    }
    public static class DecorationDictionary
    {
        public static bool TryGetValue(int key, out string value)
        {
            if (DecorationDict.TryGetValue(key, out string str))
            {
                value = str;
                return true;
            }
            value = null;
            return false;
        }
        internal static Dictionary<int, string> DecorationDict { get; } = new Dictionary<int, string>()
        {
            { 0, "None" },
            { 1, "Bold" },
            { 2, "Dim" },
            { 3, "Italic" },
            { 4, "Underline" },
            { 5, "SlowBlink" },
            { 6, "RapidBlink" },
            { 7, "Invert" },
            { 8, "Conceal" },
            { 9, "Strikethrough" },
            { 21, "BoldOff" },
            { 22, "NormalIntensity" },
            { 23, "ItalicOff" },
            { 24, "UnderlineOff" },
            { 25, "BlinkOff" },
            { 27, "InvertOff" },
            { 28, "ConcealOff" },
            { 29, "StrikethroughOff" }
                // Add more entries as needed
        };
    }
    public class Parser
    {
        private static (string slice, int placement) GetNextSlice(ref ReadOnlySpan<char> inputSpan)
        {
            var escIndex = inputSpan.IndexOf('\x1B');
            if (escIndex == -1)
            {
                return (null, 0);
            }
            // Skip the '[' character after ESC
            var sliceStart = escIndex + 2;
            if (sliceStart >= inputSpan.Length)
            {
                return (null, 0);
            }
            var slice = inputSpan.Slice(sliceStart);
            var endIndex = slice.IndexOf('m');
            if (endIndex == -1)
            {
                return (null, 0);
            }
            var vtCode = slice.Slice(0, endIndex).ToString();
            var placement = sliceStart + endIndex - vtCode.Length;
            inputSpan = inputSpan.Slice(placement);
            return (vtCode, placement);
        }
        private static VT.VtCode New4BitVT(int firstCode, int placement)
        {
            string pos = (firstCode >= 30 && firstCode <= 37 || firstCode >= 90 && firstCode <= 97) ? "foreground" : "background";
            return new VT.VtCode
            {
                Value = firstCode,
                Type = "4bit",
                Position = pos,
                Placement = placement
            };
        }
        private static VT.VtCode New8BitVT(string[] codeParts, int placement, string position)
        {
            return new VT.VtCode
            {
                Value = int.Parse(codeParts[2]),
                Type = "8bit",
                Position = position,
                Placement = placement
            };
        }
        private static VT.VtCode New24BitVT(string[] codeParts, int placement, string position)
        {
            return new VT.VtCode
            {
                Value = new VT.RGB
                {
                    Red = int.Parse(codeParts[2]),
                    Green = int.Parse(codeParts[3]),
                    Blue = int.Parse(codeParts[4])
                },
                Type = "24bit",
                Position = position,
                Placement = placement
            };
        }
        private static VT.VtCode NewDecoVT(int firstCode, int placement)
        {
            if (DecorationDictionary.TryGetValue(firstCode, out string strDeco))
            {
                return new VT.VtCode
                {
                    Value = strDeco,
                    Type = "decoration",
                    Position = "",
                    Placement = placement
                };
            }
            return null;
        }
        private static VT.VtCode NewVT(int firstCode, string[] codeParts, int placement)
        {
            if (firstCode >= 30 && firstCode <= 37 || firstCode >= 40 && firstCode <= 47 || firstCode >= 90 && firstCode <= 97 || firstCode >= 100 && firstCode <= 107)
            {
                return New4BitVT(firstCode, placement);
            }
            else if (firstCode == 38 || firstCode == 48)
            {
                string position = firstCode == 48 ? "background" : "foreground";
                if (codeParts.Length >= 3 && codeParts[1] == "5")
                {
                    return New8BitVT(codeParts, placement, position);
                }
                else if (codeParts.Length >= 5 && codeParts[1] == "2")
                {
                    return New24BitVT(codeParts, placement, position);
                }
            }
            else
            {
                return NewDecoVT(firstCode, placement);
            }
            return null;
        }
        public static List<VT.VtCode> Parse(string input)
        {
            ReadOnlySpan<char> inputSpan = input.AsSpan();
            List<VT.VtCode> results = new List<VT.VtCode>();

            while (!inputSpan.IsEmpty)
            {
                var (slice, placement) = GetNextSlice(inputSpan: ref inputSpan);
                if (slice == null)
                {
                    break;
                }

                var codeParts = slice.Split(';');
                if (codeParts.Length > 0)
                {
                    try
                    {
                        int firstCode = int.Parse(codeParts[0]);
                        VT.VtCode _vtCode = NewVT(firstCode, codeParts, placement);
                        if (_vtCode != null)
                        {
                            results.Add(_vtCode);
                        }
                    }
                    catch (FormatException)
                    {
                        // Ignore
                    }
                }
            }
            return results;
        }
    }
}
