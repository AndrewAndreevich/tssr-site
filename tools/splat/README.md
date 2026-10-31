# Rustaveli scan (last slide)

`assets/splats/rustaveli.sog` is the drone survey SCA-102 (Rustaveli Square, Tbilisi), trained with
gsplat 1.5.3 (MCMC, antialiased) from 300 RealityScan cameras, and shown with Spark 2.4.0.

## Rebuild

```bash
tools/splat/build.sh                                   # default: point_cloud_6999.ply (7k steps)
tools/splat/build.sh F:/BASE/SCANS/SCA-102_RUSTAVELI_WIDE_SITE/SPLAT/gsplat_full/ply/point_cloud_29999.ply
KEEP=2500000 tools/splat/build.sh ...                   # more splats: ~11.5 bytes each
```

The 7k source is 5,000,000 splats at 1.18 GB. The build:
- removes NaNs and the view-dependent SH bands (colour only);
- removes about 5k stray splats more than 1000 units out;
- removes splats with opacity ≤ 0.005;
- decimates adaptively to 2,000,000;
- writes Morton-ordered SOG at about 23.5 MB.

This runs in about 1.5 minutes. The output stays under the 100 MB limit for a single GitHub Pages file, so no Git LFS is needed.

## Coordinates

The scan stays in gsplat's normalized world space: z is up, and 1 unit is about 110 m. The page turns it to y-up with `rotation.x = -π/2`.

The six places in `VIEWS` (in `index.html`) are in that space. They were placed by laying the OSM building outlines over a top view of the scan:
- east/north metres → scan x/y: rotate by 73°, scale by 1/111, then offset by the Rustaveli monument at (-0.669, -0.165).
- Other OSM points can be placed the same way.

A 30k-step retrain from the same COLMAP model uses the same normalization, so the places and camera views stay valid.
