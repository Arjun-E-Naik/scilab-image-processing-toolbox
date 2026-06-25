# `bwmorph.sci` — Binary Image Morphological Operations

---

## Overview

**Binary morphological operations** reshape binary (black-and-white) images by applying
neighbourhood rules to every pixel. Each operation slides a small window over the image,
examines the pixel pattern inside, and decides what the center pixel should become.


### Calling Sequence

```scilab
exec("bwmorph.sci")            // load all functions

out = bwmorph(img, "dilate")          // run once
out = bwmorph(img, "thin", %inf)      // run until stable
out = bwmorph(img, "erode", 3)        // run exactly 3 times
```

---




#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `bw` | numeric or boolean matrix | Input binary image. |
| `operation` | string | Name of the operation to apply. |
| `n` | scalar (optional) | Number of iterations. Default is 1. Pass `%inf` to run until convergence. |

#### Output

| Parameter | Type | Description |
|-----------|------|-------------|
| `bw2` | boolean matrix | Result image, same size as `bw`. |

---

### Helper functions

| Function | Signature | What it does |
|----------|-----------|--------------|
| `bw_dilate` | `R = bw_dilate(A, se)` | Dilate `A` with structuring element `se` |
| `bw_erode` | `R = bw_erode(A, se)` | Erode `A` with structuring element `se` |
| `bw_open` | `R = bw_open(A, se)` | Erode then dilate |
| `bw_close` | `R = bw_close(A, se)` | Dilate then erode |
| `bw_tophat` | `R = bw_tophat(A, se)` | `A AND NOT open(A)` |
| `bw_bothat` | `R = bw_bothat(A, se)` | `close(A) AND NOT A` |
| `local_applylut` | `B = local_applylut(A, lut)` | Apply a 512-entry boolean LUT to every pixel using its 3×3 neighbourhood |
| `bw_thin_zs` | `bw2 = bw_thin_zs(bw, n)` | Thin binary image using the Zhang–Suen algorithm for up to `n` iterations |
| `thin_subiteration` | `[bw_out, changed] = thin_subiteration(bw, step)` | One sub-iteration of Zhang–Suen thinning (step 1 or step 2); returns updated image and a flag indicating whether any pixel changed |

---





---

## Test Cases

### Test 1 — `clean`: remove isolated pixel, keep neighboured pixel

```scilab
in  = ([0 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "clean");
// pixel at (2,1) has no white neighbours → removed
// pixel at (2,3) touches (3,3) → kept
// Expected:
// 0  0  0
// 0  0  1
// 0  0  1
```

### Test 2 — `bridge`: connect two diagonal regions

```scilab
in  = ([1 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "bridge");
// The gap pixel at (1,2) and (2,2) bridge the two disconnected regions
// Expected:
// 1  1  0
// 1  1  1
// 0  1  1
```

### Test 3 — `dilate`: single pixel expands to 3×3

```scilab
in  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
out = bwmorph(in, "dilate");
// Every pixel within the 3x3 window of the center becomes 1
// Expected: ones(3,3)
```

### Test 4 — `erode`: solid 3×3 shrinks to single center pixel

```scilab
in  = ones(3,3) ~= 0;
out = bwmorph(in, "erode");
// Only the center pixel has all 9 neighbours as 1
// Expected:
// 0  0  0
// 0  1  0
// 0  0  0
```

### Test 5 — `remove`: hollow out a filled region

```scilab
in  = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
out = bwmorph(in, "remove");
// Position (4,3): all 4 direct neighbours are 1 → removed
// Expected:
// 0  1  0  0  0
// 1  0  0  1  0
// 1  0  1  0  0
// 1  1  0  1  1
// 1  1  1  1  1
```

### Test 6 — `endpoints`: tips of skeleton branches

```scilab
in  = ([0 0 0 0 0; 0 0 1 0 0; 0 1 1 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
out = bwmorph(in, "endpoints");
// The center pixel has 4 neighbours → not an endpoint
// Each arm tip has 1 neighbour → endpoint
// Expected:
// 0  0  0  0  0
// 0  0  1  0  0
// 0  1  0  1  0
// 0  0  1  0  0
// 0  0  0  0  0
```

### Test 7 — `skel-lantuejoul`: progressive skeleton

```scilab
// 12x7 irregular blob from Gonzalez & Woods fig 8.39
slBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
         0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; ...
         0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 0 0 0 0] ~= 0);

out_n1  = bwmorph(slBW, "skel-lantuejoul", 1);    // first level only
out_n3  = bwmorph(slBW, "skel-lantuejoul", 3);    // three levels
out_inf = bwmorph(slBW, "skel-lantuejoul", %inf); // full skeleton
```

### Test 8 — `thin` (Zhang–Suen): thin a thick horizontal bar

```scilab
in  = ones(5, 7) ~= 0;
out = bwmorph(in, "thin", %inf);
// The 5-row bar is thinned to a single 1-pixel-wide horizontal stroke.
```

---

## Running the Tests

```scilab
exec("bwmorph.sci")       // load all functions
exec("test_bwmorph.sci")  // run all assertions, prints PASS/FAIL for each
```
