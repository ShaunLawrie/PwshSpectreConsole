using System;
using System.Collections.Generic;
using System.Reflection;
using Spectre.Console;
using Spectre.Console.Rendering;

namespace PwshSpectreConsole.Extensions;

public static class LayoutExtensions {
    private static readonly MethodInfo MakeRegionMapMethod =
        typeof(Layout).GetMethod("MakeRegionMap", BindingFlags.NonPublic | BindingFlags.Instance)
        ?? throw new MissingMethodException("Layout.MakeRegionMap not found");

    public static Dictionary<string, Region> GetLayoutRegions(this Layout layout, RenderOptions options, int maxWidth) {
        int height = options.Height ?? options.ConsoleSize.Height;
        var regionMap = (System.Collections.IEnumerable)MakeRegionMapMethod.Invoke(layout, [maxWidth, height])!;

        var result = new Dictionary<string, Region>(StringComparer.OrdinalIgnoreCase);
        foreach (object? item in regionMap) {
            var tuple = ((Layout Layout, Region Region))item;
            if (tuple.Layout.Name != null) {
                result[tuple.Layout.Name] = tuple.Region;
            }
        }

        return result;
    }
}