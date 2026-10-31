"""Roof-height map of the scan, so the page can keep its camera above the splats.

    python tools/splat/heights.py pruned.ply assets/splats/rustaveli_heights.bin

Reads the decimated PLY that build.sh makes (raw RealityScan frame), moves the splats into the
page's frame (gsplat-normalized, z up; the same NORM as in index.html) and stores, for a grid over
x, y in [-R, R], the highest solid splat per cell, widened by a couple of cells so the camera keeps
clear of walls too. One byte per cell: height = Z0 + value * DZ (0 = nothing there).
"""
import sys
import numpy as np

NORM = np.array([
    [0.00921831, 0.00159341, -0.00405399, 0.06303984],
    [0.0043536, -0.00306282, 0.00869576, 0.0112516],
    [0.00014116, -0.00959329, -0.00344962, -0.18225071],
    [0, 0, 0, 1]])
SCALE = np.cbrt(abs(np.linalg.det(NORM[:3, :3])))   # raw unit -> normalized unit
R, N = 3.0, 300                                      # grid: [-R, R]^2, N x N cells (2 cm = ~2 m)
Z0, DZ = -1.0, 0.01                                  # heights -1 ... 1.54 in normalized units
WIDEN = 2                                            # cells added round every solid cell


def read_ply(path):
    with open(path, 'rb') as f:
        names, count = [], 0
        while (line := f.readline().decode().strip()) != 'end_header':
            parts = line.split()
            if parts[:2] == ['element', 'vertex']:
                count = int(parts[2])
            elif parts[0] == 'property':
                names.append(parts[2])
        data = np.fromfile(f, dtype=np.float32, count=count * len(names)).reshape(count, len(names))
    return {n: data[:, i] for i, n in enumerate(names)}


def main(src, dst):
    v = read_ply(src)
    opacity = 1 / (1 + np.exp(-v['opacity']))
    size = np.exp(np.maximum(np.maximum(v['scale_0'], v['scale_1']), v['scale_2'])) * SCALE
    keep = (opacity > .5) & (size < .03)            # solid and small: no sky or haze blobs
    p = np.c_[v['x'][keep], v['y'][keep], v['z'][keep], np.ones(keep.sum())] @ NORM.T
    i = np.floor((p[:, 0] + R) / (2 * R) * N).astype(int)
    j = np.floor((p[:, 1] + R) / (2 * R) * N).astype(int)
    q = np.clip(np.round((p[:, 2] - Z0) / DZ), 1, 255).astype(np.uint8)
    inside = (i >= 0) & (i < N) & (j >= 0) & (j < N)
    grid = np.zeros((N, N), np.uint8)                # [j][i]: row = y, column = x
    np.maximum.at(grid, (j[inside], i[inside]), q[inside])
    wide = grid.copy()
    for dj in range(-WIDEN, WIDEN + 1):
        for di in range(-WIDEN, WIDEN + 1):
            wide = np.maximum(wide, np.roll(np.roll(grid, dj, 0), di, 1))
    wide.tofile(dst)
    print(f'{dst}: {N}x{N}, {keep.sum()} solid splats, {(wide > 0).mean():.0%} of cells covered')


if __name__ == '__main__':
    main(*sys.argv[1:3])
