# `bwmorph.sci` — Binary Image Morphological Operations

---

## Overview

**Binary morphological operations** reshape binary (black-and-white) images by applying
neighbourhood rules to every pixel. Each operation slides a small window over the image,
examines the pixel pattern inside, and decides what the center pixel should become.


### How to use

```scilab
exec("bwmorph.sci")            // load all functions

out = bwmorph(img, "dilate")          // run once
out = bwmorph(img, "thin", %inf)      // run until stable
out = bwmorph(img, "erode", 3)        // run exactly 3 times
```

---



### `bwmorph(bw, operation [, n])`

```scilab
bw2 = bwmorph(bw, operation)
bw2 = bwmorph(bw, operation, n)
```

Performs the named morphological operation on binary image `bw`, repeated `n` times.

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

## Variables

### Main function variables

| Variable | Description |
|----------|-------------|
| `bw` | Primary input binary image. Converted to boolean at the start of `bwmorph`. |
| `operation` | String name of the morphological operation to run. |
| `n` | Number of iterations. Default 1. `%inf` means run until stable. |
| `op` | Lowercase copy of `operation` (from `convstr`), used for case-insensitive dispatch. |
| `se3` | 3×3 all-ones structuring element used by dilate, erode, open, close, tophat, bothat. |
| `loop_once` | Boolean flag. Set to `%t` for idempotent operations — applying them more than once gives the same result, so `n` is clamped to 1. |
| `morph_tag` | String tag that tells the iteration loop which code path to execute. Possible values: `"dilate"`, `"erode"`, `"open"`, `"close"`, `"tophat"`, `"bothat"`, `"lut1"`, `"lut1_and"`, `"conv_gt"`, `"conv_ge"`, `"done"`. |
| `v`, `v1`, `v2` | Temporary integer column vectors (512×1) holding raw LUT data (0s and 1s). Converted to boolean with `(v ~= 0)`. |
| `lut1`, `lut2` | Boolean column vectors (512×1). The lookup tables used by LUT-based operations. |
| `post_bridge` | Boolean flag. Set to `%t` for `skel`, which runs a bridge pass after each thinning iteration to reconnect broken skeleton segments. |
| `K` | Convolution kernel matrix for operations that use `conv_gt` or `conv_ge`. |
| `thresh` | Numeric threshold for convolution-based operations. |
| `bw2_tmp` | Temporary result matrix holding the output of the current iteration. Becomes `bw2` at the end. |
| `i` | Loop counter for the iteration while-loop. |
| `acc` | Accumulator boolean matrix used by `skel-lantuejoul` to collect results across erosion levels. |
| `iter` | Inner iteration counter inside `skel-lantuejoul`. |
| `ebw` | Eroded version of the current image inside `skel-lantuejoul`. |

### `local_applylut` variables

| Variable | Description |
|----------|-------------|
| `A` | Input boolean image to which the LUT is applied. |
| `lut` | 512×1 boolean column vector; the lookup table. |
| `W` | 3×3 weight matrix `[1 2 4; 8 16 32; 64 128 256]` passed to `conv2`. Weights are arranged so that after `conv2` slides the kernel, each neighbour contributes the correct power-of-two to the index. |
| `idx` | Integer matrix (same size as `A`) containing the 1-based LUT index for each pixel. |
| `B` | Output boolean matrix (same size as `A`). |

### `bw_thin_zs` / `thin_subiteration` variables

| Variable | Description |
|----------|-------------|
| `bw` | Working copy of the image (converted to `double` 0/1 inside `bw_thin_zs`). |
| `changed` | Boolean flag; `%t` if any pixel was removed during the current full iteration. |
| `changed1`, `changed2` | Per-sub-iteration change flags. |
| `iter` | Iteration counter in `bw_thin_zs`. |
| `marker` | Matrix of the same size as `bw`; pixels marked `1` will be removed at the end of the sub-iteration. |
| `p2`–`p9` | The eight neighbours of the current pixel in N, NE, E, SE, S, SW, W, NW order. |
| `B` | Neighbour sum (number of foreground neighbours, 0–8). |
| `A` | Number of 0→1 transitions in the ordered neighbour ring. |
| `neighbours` | Length-9 array `[p2, p3, …, p9, p2]` used to count transitions. |
| `step` | Sub-iteration selector (1 or 2); controls which pair of conditions is checked. |

### Helper function variables

| Variable | Description |
|----------|-------------|
| `se` | Structuring element passed to helper functions (typically `se3 = ones(3,3)`). |
| `full` | `sum(se(:))` — the maximum possible conv2 result, used as the erosion threshold. |

---

## Supported Operations

| Operation | Idempotent | Description |
|-----------|-----------|-------------|
| `bothat` | yes | `close(bw) AND NOT bw` — highlights dark spots smaller than the SE |
| `bridge` | yes | Sets a 0-pixel to 1 when it bridges two disconnected 1-pixel regions |
| `clean` | yes | Removes isolated 1-pixels whose all 8 neighbours are 0 |
| `close` | yes | Dilate then erode — fills small holes and gaps |
| `diag` | no | Diagonal fill — prevents diagonal gaps between foreground regions |
| `dilate` | no | Grows every foreground region outward by one pixel |
| `endpoints` | — | Finds branch tips in a skeleton (pixels with exactly one neighbour) |
| `erode` | no | Shrinks every foreground region inward by one pixel |
| `fill` | yes | Sets a 0-pixel to 1 if all four 4-connected neighbours are 1 |
| `hbreak` | yes | Breaks H-shaped junctions in skeletons |
| `majority` | no | Sets a pixel to 1 if 5 or more of the 9 pixels in its 3×3 window are 1 |
| `open` | yes | Erode then dilate — removes small protrusions |
| `remove` | yes | Removes interior pixels (all four 4-connected neighbours are 1) |
| `shrink` | no | Shrinks objects to single pixels (no holes) or rings (with holes) |
| `skel` | no | Skeletonization using Pratt's two-LUT algorithm; applies a bridge pass after each iteration |
| `skel-lantuejoul` | no | Skeletonization using Lantuejoul's method (union of tophat levels) |
| `spur` | no | Removes dead-end (spur) pixels from a skeleton |
| `thin` | no | Thins objects to 1-pixel-wide strokes using the Zhang–Suen algorithm |
| `tophat` | yes | `bw AND NOT open(bw)` — highlights small bright features |

---

## Algorithm Explanation

### Convolution-based operations

Dilation, erosion, clean, fill, remove, and majority all use `conv2` internally.

```
bw_dilate:   conv2(bw, ones(3,3)) > 0
             Any pixel with at least one white neighbour becomes white.

bw_erode:    conv2(bw, ones(3,3)) >= 9
             A pixel stays white only when all 9 neighbourhood pixels are white.

clean:       conv2(bw, K) > 8   where K = ones(3,3) with center = 8
             conv = 8 means center=1 but all neighbours are 0  → remove
             conv > 8 means center=1 and at least one neighbour is 1  → keep

fill:        conv2(bw, K) >= 4  where K = cross with center = 4
             conv >= 4 means center=1 (stays) OR center=0 with all 4 direct neighbours=1

remove:      conv2(bw, K) > 0   where K = [0 -1 0; -1 4 -1; 0 -1 0]
             center=1, all 4 direct nbrs=1  → 4-4=0  not > 0  → remove
             center=1, any direct nbr=0     → 4-k > 0         → keep

majority:    conv2(bw, ones(3,3)) >= 5
             Sum >= 5 means 5 or more of the 9 pixels are 1.
```

### LUT-based operations

Bridge, diag, endpoints, hbreak, spur, shrink, and skel all use look-up tables.
Each pixel's 3×3 neighbourhood is encoded as a 9-bit integer (the LUT index),
and the table entry tells us what the center pixel should become.

**Neighbourhood bit layout:**

```
   X3  X2  X1
   X4   X  X0
   X5  X6  X7

index = 1 + X0*1 + X1*2 + X2*4 + X3*8 + X4*16
            + X5*32 + X6*64 + X7*128 + Xcenter*256
```

With 9 binary pixels there are 2^9 = 512 possible patterns, so each LUT has
exactly 512 entries. The LUT is stored as a 512×1 boolean column vector.

**Why the weight matrix is `[1 2 4; 8 16 32; 64 128 256]`:**

`conv2` slides the kernel over the image in standard correlation fashion. The
weights are arranged in row-major order so that each position contributes the
correct power-of-two corresponding to its bit in the index formula above,
mapping directly to the expected 9-bit neighbourhood encoding.

**Two-LUT operations (shrink, skel):**

```
Step 1:  mid  = lut1(bw)           mark candidates for deletion
Step 2:  out  = lut2(mid)          veto deletions that break topology
Step 3:  bw2  = bw AND out         apply only safe deletions (never add pixels)
```

### Zhang–Suen thinning algorithm (`thin`)

The `thin` operation uses the Zhang–Suen iterative thinning algorithm implemented
in `bw_thin_zs`. Each full iteration consists of two sub-iterations.

**Per-pixel conditions (both sub-iterations):**

1. The pixel is currently foreground (`bw(i,j) == 1`).
2. It has between 2 and 6 foreground neighbours (connectivity condition).
3. Its ordered neighbour ring contains exactly one 0→1 transition (simple point condition).

**Sub-iteration-specific conditions:**

```
Sub-iteration 1:  p2 * p4 * p6 == 0   AND   p4 * p6 * p8 == 0
Sub-iteration 2:  p2 * p4 * p8 == 0   AND   p2 * p6 * p8 == 0
```

where p2=N, p4=E, p6=S, p8=W in the standard Zhang–Suen labelling.

Pixels satisfying all conditions in a sub-iteration are collected into a marker
matrix and removed simultaneously at the end of that sub-iteration. The algorithm
stops when neither sub-iteration removes any pixel.

### Iteration loop

```
if loop_once then clamp n to 1   // skip redundant iterations
bw2_tmp = bw                     // initialise result

while i <= n:
    apply the selected morph_tag code path
    if image unchanged: break early   // convergence
    bw = bw2_tmp
    i++

if post_bridge: bwmorph(bw2_tmp, "bridge")   // skel only
bw2 = bw2_tmp
```

### skel-lantuejoul algorithm

```
acc = all-zeros image

for i = 1 to n:
    if bw is all-zeros: stop
    ebw     = erode(bw)
    top_hat = bw AND NOT dilate(ebw)   // pixels lost at this erosion level
    acc     = acc OR top_hat           // accumulate skeleton
    bw      = ebw                      // next level

return acc
```

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
