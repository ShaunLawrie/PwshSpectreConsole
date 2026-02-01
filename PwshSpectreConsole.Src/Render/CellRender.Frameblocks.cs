namespace PwshSpectreConsole.Render;

public static partial class CellRender {
    internal static void RenderBlockElements(Image<Rgba32> image, ref ImageCanvas canvas) {
        int canvasWidth = canvas.Width;
        int canvasHeight = canvas.Height;

        int cellPixelWidth = Math.Max(1, image.Width / Math.Max(1, canvasWidth));

        for (int cy = 0; cy < canvasHeight; cy++) {
            int yTop = Math.Clamp((int)Math.Round((cy + 0.25) * image.Height / canvasHeight), 0, image.Height - 1);
            int yBottom = Math.Clamp((int)Math.Round((cy + 0.75) * image.Height / canvasHeight), 0, image.Height - 1);

            for (int cx = 0; cx < canvasWidth; cx++) {
                int xCell = cx * cellPixelWidth;
                int sampleX = xCell + (cellPixelWidth / 2);
                if (sampleX >= image.Width) sampleX = image.Width - 1;

                // Build a high-resolution sample grid for this cell (8x8) and choose
                // the best glyph from the full block category U+2581..U+2588 and U+258F..U+2588
                // (vertical fractions and left-width fractions) plus full/half blocks.
                int Sx = Math.Min(8, Math.Max(1, cellPixelWidth));
                int Sy = 8;
                bool[,] sample = new bool[Sx, Sy];
                int[,] rAcc = new int[Sx, Sy];
                int[,] gAcc = new int[Sx, Sy];
                int[,] bAcc = new int[Sx, Sy];
                int totalOn = 0;

                for (int sx = 0; sx < Sx; sx++) {
                    int px = Math.Clamp(xCell + (int)Math.Round((sx + 0.5) * cellPixelWidth / Sx), 0, image.Width - 1);
                    for (int sy = 0; sy < Sy; sy++) {
                        double rel = (sy + 0.5) / Sy; // top..bottom
                        int py = Math.Clamp((int)Math.Round((cy + rel) * image.Height / canvasHeight), 0, image.Height - 1);
                        Rgba32 pxl = image[px, py];
                        bool on = !IsTransparent(pxl);
                        sample[sx, sy] = on;
                        if (on) {
                            rAcc[sx, sy] = pxl.R; gAcc[sx, sy] = pxl.G; bAcc[sx, sy] = pxl.B;
                            totalOn++;
                        }
                    }
                }

                if (totalOn == 0) continue;

                // Remove isolated speckles: require at least two neighbouring "on" samples
                bool[,] filtered = new bool[Sx, Sy];
                for (int sx = 0; sx < Sx; sx++) {
                    for (int sy = 0; sy < Sy; sy++) {
                        if (!sample[sx, sy]) { filtered[sx, sy] = false; continue; }
                        int neigh = 0;
                        for (int ix = Math.Max(0, sx - 1); ix <= Math.Min(Sx - 1, sx + 1); ix++) {
                            for (int iy = Math.Max(0, sy - 1); iy <= Math.Min(Sy - 1, sy + 1); iy++) {
                                if (ix == sx && iy == sy) continue;
                                if (sample[ix, iy]) neigh++;
                            }
                        }
                        filtered[sx, sy] = neigh >= 2;
                    }
                }

                int filteredOn = 0;
                for (int sx = 0; sx < Sx; sx++) for (int sy = 0; sy < Sy; sy++) if (filtered[sx, sy]) filteredOn++;
                if (filteredOn == 0) continue;

                // If the filter removed a large fraction of samples, it's probably
                // over-aggressive on thin strokes. In that case, fall back to the
                // original `sample` mask for scoring and averaging.
                bool useFiltered = filteredOn >= (int)Math.Ceiling(totalOn * 0.6);
                bool[,] maskSource = useFiltered ? filtered : sample;

                // Candidate glyphs: vertical fills (1..8 bottom rows), horizontal left widths (1..8), full block
                // Choose best glyph by comparing vertical vs horizontal candidates.
                int bestCp = 0;
                int bestScore = int.MaxValue;

                // best vertical candidate (bottom n rows)
                int bestVertCp = 0; int bestVertScore = int.MaxValue;
                for (int n = 1; n <= 8; n++) {
                    int score = 0;
                    for (int sx = 0; sx < Sx; sx++) {
                        for (int sy = 0; sy < Sy; sy++) {
                            bool mask = sy >= Sy - n;
                            if (maskSource[sx, sy] && !mask) score += 2; else if (!maskSource[sx, sy] && mask) score += 1;
                        }
                    }
                    if (score < bestVertScore) { bestVertScore = score; bestVertCp = 0x2580 + n; }
                }

                // best horizontal candidate (left width w)
                int bestHorzCp = 0; int bestHorzScore = int.MaxValue;
                for (int w = 1; w <= 8; w++) {
                    int score = 0;
                    for (int sx = 0; sx < Sx; sx++) {
                        for (int sy = 0; sy < Sy; sy++) {
                            bool mask = sx < Math.Round(w * (Sx / 8.0));
                            if (maskSource[sx, sy] && !mask) score += 2; else if (!maskSource[sx, sy] && mask) score += 1;
                        }
                    }
                    int cp = 0x2588 + (8 - w); // w=8 -> 0x2588, w=1 -> 0x258F
                    if (score < bestHorzScore) { bestHorzScore = score; bestHorzCp = cp; }
                }

                // full block candidate score (penalize off samples)
                int fullScore = 0;
                for (int sx = 0; sx < Sx; sx++) for (int sy = 0; sy < Sy; sy++) if (!maskSource[sx, sy]) fullScore += 1;

                // prefer vertical when its score is within 20% of horizontal score, to avoid horizontal bleeding
                if (bestVertScore <= bestHorzScore * 1.2) {
                    bestCp = bestVertCp; bestScore = bestVertScore;
                }
                else {
                    bestCp = bestHorzCp; bestScore = bestHorzScore;
                }

                int totalSamples = Sx * Sy;
                double coverage = (double)filteredOn / Math.Max(1, totalSamples);

                // Count on-samples on the cell border to avoid choosing full-block
                // when the interior is full but borders are thin/empty (creates rough edges).
                int borderOn = 0;
                int edgeCount = 0;
                for (int sx = 0; sx < Sx; sx++) {
                    for (int sy = 0; sy < Sy; sy++) {
                        if (sx == 0 || sx == Sx - 1 || sy == 0 || sy == Sy - 1) {
                            edgeCount++;
                            if (filtered[sx, sy]) borderOn++;
                        }
                    }
                }
                double borderCoverage = edgeCount > 0 ? (double)borderOn / edgeCount : 0.0;

                // Prefer full block only when coverage is extremely high and edges are filled,
                // or when full block clearly outperforms others and edges are mostly filled.
                if (coverage >= 0.985 && borderCoverage >= 0.92) {
                    bestCp = 0x2588; bestScore = fullScore;
                }
                else if (fullScore < bestScore * 0.4 && borderCoverage >= 0.9) {
                    bestCp = 0x2588; bestScore = fullScore;
                }

                // Compute average color for pixels that are "on" (filtered true)
                long rSum = 0, gSum = 0, bSum = 0, count = 0;
                for (int sx = 0; sx < Sx; sx++) {
                    for (int sy = 0; sy < Sy; sy++) {
                        if (filtered[sx, sy]) {
                            rSum += rAcc[sx, sy]; gSum += gAcc[sx, sy]; bSum += bAcc[sx, sy]; count++;
                        }
                    }
                }

                if (count == 0) continue;
                byte R = (byte)(rSum / count);
                byte G = (byte)(gSum / count);
                byte B = (byte)(bSum / count);

                canvas.SetCell(cx, cy, (char)bestCp, new Color(R, G, B));
            }
        }
    }
}
