using System;
using System.Globalization;
using System.IO;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Text.Json;
using Spectre.Console;
using Spectre.Console.Rendering;
using System.Collections.Generic;
using System.Text.RegularExpressions;

// I tried this as a powershell class but ran into the main thread being deadlocked and hanging the terminal
namespace PwshSpectreConsole.Recording
{
    // Used to generate docs
    // https://github.com/spectreconsole/spectre.console/blob/main/resources/scripts/Generator/Commands/AsciiCast/AsciiCastOut.cs
    internal class AsciiCastWriter : TextWriter
    {
        private StringBuilder _builder = new StringBuilder();
        private decimal _firstTick;

        public AsciiCastWriter()
        {
            _firstTick = 0;
        }

        public override void Write(string value)
        {
            System.Console.Write(value);
            if (_firstTick == 0)
            {
                _firstTick = Environment.TickCount;
            }
            decimal tick = (Environment.TickCount - _firstTick) / 1000;
            _builder.Append('[').AppendFormat(CultureInfo.InvariantCulture, "{0}", tick).Append(", \"o\", \"").Append(JsonEncodedText.Encode(value)).AppendLine("\"]");
        }

        public override Encoding Encoding => Encoding.Default;

        public string GetOutput()
        {
            string json = _builder.ToString();
            _builder.Clear();
            _firstTick = 0;
            return json;
        }
    }

    public class AsciiCastInput : IAnsiConsoleInput
    {
        private readonly Queue<(ConsoleKeyInfo?, int)> _input;
        private readonly Random _random = new Random();
        private int _keyEntries = 0;

        public AsciiCastInput()
        {
            _input = new Queue<(ConsoleKeyInfo?, int)>();
        }

        public void PushText(string input, int keypressDelayMs)
        {
            if (input is null)
            {
                throw new ArgumentNullException(nameof(input));
            }

            foreach (var character in input)
            {
                PushCharacter(character, keypressDelayMs);
            }

            _keyEntries++;
        }

        public void PushTextWithEnter(string input, int keypressDelayMs)
        {
            PushText(input, keypressDelayMs);
            PushKey(ConsoleKey.Enter, keypressDelayMs);
        }

        public void PushCharacter(char input, int keypressDelayMs)
        {
            var delay = keypressDelayMs + _random.Next((int)(keypressDelayMs * -.2), (int)(keypressDelayMs * .2));

            switch (input)
            {
                case '↑':
                    PushKey(ConsoleKey.UpArrow, keypressDelayMs);
                    break;
                case '↓':
                    PushKey(ConsoleKey.DownArrow, keypressDelayMs);
                    break;
                case '↲':
                    PushKey(ConsoleKey.Enter, keypressDelayMs);
                    break;
                case '¦':
                    _input.Enqueue((null, delay));
                    break;
                default:
                    var control = char.IsUpper(input);
                    _input.Enqueue((new ConsoleKeyInfo(input, (ConsoleKey)input, false, false, control), delay));
                    break;
            }
        }

        public void PushKey(ConsoleKey input, int keypressDelayMs)
        {
            var delay = keypressDelayMs + _random.Next((int)(keypressDelayMs * -.2), (int)(keypressDelayMs * .2));
            _input.Enqueue((new ConsoleKeyInfo((char)input, input, false, false, false), delay));
            _keyEntries++;
        }

        public bool IsKeyAvailable()
        {
            return _input.Count > 0;
        }

        public ConsoleKeyInfo? ReadKey(bool intercept)
        {
            if (_input.Count == 0)
            {
                throw new InvalidOperationException("No input available.");
            }

            var result = _input.Dequeue();

            System.Threading.Thread.Sleep(result.Item2);
            return result.Item1;
        }

        public Task<ConsoleKeyInfo?> ReadKeyAsync(bool intercept, CancellationToken cancellationToken)
        {
            return Task.FromResult(ReadKey(intercept));
        }

        public int KeyEntries => _keyEntries;
    }

    public class RecordingConsole : IAnsiConsole
    {
        private IAnsiConsole _ansiConsole;
        private AsciiCastWriter _writer;
        public AsciiCastInput Input { get; }

        public RecordingConsole(int width, int height)
        {
            var profileEnrichment = new ProfileEnrichment();
            profileEnrichment.UseDefaultEnrichers = false;

            var asciiCast = new AsciiCastWriter();
            var output = new AnsiConsoleOutput(asciiCast);

            var settings = new AnsiConsoleSettings
            {
                Ansi = AnsiSupport.Yes,
                ColorSystem = ColorSystemSupport.TrueColor,
                Interactive = InteractionSupport.Yes,
                Enrichment = profileEnrichment,
                Out = output
            };

            var console = AnsiConsole.Create(settings);
            console.Profile.Width = width;
            console.Profile.Height = height;
            console.Profile.Capabilities.Ansi = true;
            console.Profile.Capabilities.Unicode = true;
            console.Profile.Out = output;

            _ansiConsole = console;
            _writer = asciiCast;
            Input = new AsciiCastInput();
        }

        public string GetAsciiCastRecording(string title)
        {
            string json = _writer.GetOutput();
            json = Regex.Replace(json, @"\\n", @"\r\n");
            json = Regex.Replace(json, @"\\r\\r\\n", @"\r\n");
            // count number of times [2A appears in the json
            var cursorUps = Regex.Matches(json, @"\[([0-9]+)A");
            var countOfCursorUps = 0;
            foreach (Match cursorUp in cursorUps)
            {
                countOfCursorUps += int.Parse(cursorUp.Groups[1].Value);
            }
            var KeyEntries = Input.KeyEntries;
            var countOfNewlines = Regex.Matches(json, @"\\n").Count;
            var jsonStrippedOfNewlines = Regex.Replace(json, @"(\\r)?\\n", "");
            var totalLines = countOfNewlines - countOfCursorUps + KeyEntries + 2;
            string header = $"{{\"version\": 2, \"width\": {_ansiConsole.Profile.Width}, \"height\": {totalLines}, \"title\": \"{JsonEncodedText.Encode(title)}\", \"env\": {{\"TERM\": \"Spectre.Console\"}}}}";
            return $"{header}{Environment.NewLine}{json}{Environment.NewLine}";
        }

        public Profile Profile => _ansiConsole.Profile;
        public IAnsiConsoleCursor Cursor => _ansiConsole.Cursor;
        IAnsiConsoleInput IAnsiConsole.Input => Input;
        public IExclusivityMode ExclusivityMode => _ansiConsole.ExclusivityMode;
        public RenderPipeline Pipeline => _ansiConsole.Pipeline;

        public void Clear(bool homeValue)
        {
            _ansiConsole.Clear(homeValue);
        }

        public void Write(IRenderable renderable)
        {
            _ansiConsole.Write(renderable);
        }
    }
}
