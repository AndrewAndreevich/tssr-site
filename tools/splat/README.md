# Rustaveli scan (last slide)

`assets/splats/rustaveli.sog` is the drone survey SCA-102 of Rustaveli Square, Tbilisi. It was trained with Brush 0.3.0 for 15k steps on 300 RealityScan cameras and is shown with Spark 2.4.0.

## Rebuild

```bash
tools/splat/build.sh                                   # default: EXPORT_brush_15k/rustaveli_splat_brush_15k.ply
tools/splat/build.sh F:/BASE/SCANS/SCA-102_RUSTAVELI_WIDE_SITE/SPLAT/brush_out/export_30000.ply
KEEP=4000000 tools/splat/build.sh ...                   # more splats: ~12.7 bytes each
```

The 15k source has 6,000,000 splats with SH degree 3 and weighs 1.42 GB. The build does four things:
- removes the view-dependent SH bands and keeps colour only;
- removes splats with opacity of 0.005 or less;
- decimates adaptively to 3,000,000 splats;
- writes a Morton-ordered SOG of about 38 MB.

It takes about a minute. One file is under the 100 MB GitHub Pages limit, so Git LFS is not needed.

## Coordinates

The SOG keeps the PLY's raw RealityScan/COLMAP frame: −y up, about 1.1 m per unit.

The page works in gsplat's normalized frame of the same COLMAP cameras: z up, 1 unit ≈ 110 m. Two transforms connect them:
- `NORM` in `index.html` maps raw to normalized. It is gsplat 1.5.3's `similarity_from_cameras` → `align_principal_axes` → z-flip, computed from `SPLAT/colmap/sparse/0`. It is a similarity with no mirror; 1 normalized unit = 98 raw units.
- After that, the page turns it y-up with a −90° turn about x.

Any export trained on that COLMAP model drops in without code changes, such as Brush 30k or gsplat.

The camera views and the six places (`OVERVIEW` and `VIEWS`) are in normalized coordinates. They were placed by laying OSM building outlines over a top view of the scan. To place a geographic point:
1. Convert it to east/north metres from the Rustaveli monument.
2. Rotate by 73°.
3. Scale by 1/111.
4. Add the monument's position, (-0.669, -0.165).
