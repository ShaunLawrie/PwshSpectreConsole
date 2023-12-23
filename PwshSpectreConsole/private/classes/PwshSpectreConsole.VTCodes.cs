using System;
using System.Collections.Generic;
using System.Management.Automation;
// using Spectre.Console;

namespace PwshSpectreConsole.VTCodes
{
    public class VT
    {
        // objects of this class are returned by the Parser
        public class VtCode
        {
            public object Value { get; set; }
            public string Type { get; set; }
            public string Position { get; set; }
            public int Placement { get; set; }
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
        { 0, "reset" },
        { 1, "bold" },
        { 2, "faint" },
        { 3, "italic" },
        { 4, "underline" },
        { 5, "blinkSlow" },
        { 6, "blinkRapid" },
        { 7, "reverseVideo" },
        { 8, "conceal" },
        { 9, "crossedOut" },
        { 21, "boldOff" },
        { 22, "normalIntensity" },
        { 23, "italicOff" },
        { 24, "underlineOff" },
        { 25, "blinkOff" },
        { 27, "inverseOff" },
        { 28, "concealOff" },
        { 29, "crossedOutOff" },
        { 39, "defaultForeground" },
        { 49, "defaultBackground" }
            // Add more entries as needed
        };
    }
    public class Parser
    {
        private static (string slice, int position) GetNextSlice(ref ReadOnlySpan<char> inputSpan)
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
            var position = sliceStart + endIndex - vtCode.Length;
            inputSpan = inputSpan.Slice(position);
            return (vtCode, position);
        }
        private static VT.VtCode New4BitVT(int firstCode, int position)
        {
            string pos = (firstCode >= 30 && firstCode <= 37 || firstCode >= 90 && firstCode <= 97) ? "foreground" : "background";
            return new VT.VtCode
            {
                Value = firstCode,
                Type = "4bit",
                Position = pos,
                Placement = position
            };
        }
        private static VT.VtCode New8BitVT(string[] codeParts, int position, string type)
        {
            return new VT.VtCode
            {
                Value = int.Parse(codeParts[2]),
                Type = "8bit",
                Position = type,
                Placement = position
            };
        }
        private static VT.VtCode New24BitVT(string[] codeParts, int position, string type)
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
                Position = type,
                Placement = position
            };
        }
        private static VT.VtCode NewDecoVT(int firstCode, int position)
        {
            if (DecorationDictionary.TryGetValue(key: firstCode, value: out string strDeco))
            {
                return new VT.VtCode
                {
                    Value = strDeco,
                    Type = "decoration",
                    Position = "",
                    Placement = position
                };
            }
            return null;
        }
        private static VT.VtCode NewVT(int firstCode, string[] codeParts, int position)
        {
            if (firstCode >= 30 && firstCode <= 37 || firstCode >= 40 && firstCode <= 47 || firstCode >= 90 && firstCode <= 97)
            {
                return New4BitVT(firstCode: firstCode, position: position);
            }
            else if (firstCode == 38 || firstCode == 48)
            {
                string type = firstCode == 48 ? "background" : "foreground";
                if (codeParts.Length >= 3 && codeParts[1] == "5")
                {
                    return New8BitVT(codeParts: codeParts, position: position, type: type);
                }
                else if (codeParts.Length >= 5 && codeParts[1] == "2")
                {
                    return New24BitVT(codeParts: codeParts, position: position, type: type);
                }
            }
            else
            {
                return NewDecoVT(firstCode: firstCode, position: position);
            }
            return null;
        }
        public static List<VT.VtCode> Parse(string input)
        {
            ReadOnlySpan<char> inputSpan = input.AsSpan();
            List<VT.VtCode> results = new List<VT.VtCode>();

            while (!inputSpan.IsEmpty)
            {
                var (slice, position) = GetNextSlice(inputSpan: ref inputSpan);
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
                        VT.VtCode _vtCode = NewVT(firstCode: firstCode, codeParts: codeParts, position: position);
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
