namespace PwshSpectreConsole.Utilities;

internal ref struct ValueStringBuilder {
    private char[]? _array;
    private Span<char> _span;

    public ValueStringBuilder(int initialCapacity = 256) {
        _array = ArrayPool<char>.Shared.Rent(initialCapacity);
        _span = _array;
        Length = 0;
    }

    public void Append(char c) {
        if (Length >= _span.Length) Grow();
        _span[Length++] = c;
    }

    public void Append(ReadOnlySpan<char> s) {
        if (s.IsEmpty) return;
        if (Length + s.Length > _span.Length) Grow(Length + s.Length);
        s.CopyTo(_span[Length..]);
        Length += s.Length;
    }

    public int Length { get; private set; }

    private void Grow(int min = 0) {
        int newSize = Math.Max(_span.Length * 2, Math.Max(min, 256));
        char[] newArr = ArrayPool<char>.Shared.Rent(newSize);
        _span.CopyTo(newArr);
        char[]? old = _array;
        _array = newArr;
        _span = _array;
        if (old != null) ArrayPool<char>.Shared.Return(old);
    }

    public readonly ReadOnlySpan<char> AsSpan() => _span[..Length];

    public override string ToString() {
        string s = new(_span[..Length]);
        if (_array != null) { ArrayPool<char>.Shared.Return(_array); _array = null; }
        _span = [];
        Length = 0;
        return s;
    }
}
