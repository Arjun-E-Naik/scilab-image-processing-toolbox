# `rangefilt.sci` — Range Filtering



---

## Overview

**Range filtering** is a non-linear spatial image processing operation that
replaces each pixel with the **local range** — the difference between the
maximum and minimum pixel values within a defined neighbourhood. It is
particularly effective for **edge and texture detection**, highlighting regions
of high local contrast while producing zero (flat) output in homogeneous areas.

Typical interpretation of `rangefilt` output:

| Output Value | Meaning |
|--------------|---------|
| 0 | Completely flat / uniform region |
| Low | Smooth gradient or low-contrast area |
| High | Sharp edge, texture boundary, or noisy region |
| Max (= peak range) | Maximum local contrast within the neighbourhood |

---

## Function Reference

### `rangefilt(I[, domain[, padding]])`

```scilab
retval = rangefilt(I)
retval = rangefilt(I, domain)
retval = rangefilt(I, domain, padding)
```

Computes the local range image of `I` using a structuring element defined by
`domain`, after padding the image boundary with the strategy specified by
`padding`.

#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `I` | numeric or logical matrix | Input image. Accepted types: `double` (type 1), `boolean` (type 4), or integer (`uint8`, `int16`, etc., type 8). |
| `domain` | numeric or logical matrix (optional) | Neighbourhood structuring element. Non-zero entries mark active neighbours. Defaults to a 3 × 3 matrix of ones (full square neighbourhood). |
| `padding` | string (optional) | Border-extension method applied before filtering. Currently supports `"symmetric"`. Defaults to `"symmetric"`. |

#### Output

| Parameter | Type | Description |
|-----------|------|-------------|
| `retval` | double matrix | Local range image. Same spatial dimensions as the input `I`. Each element holds `max(neighbourhood) − min(neighbourhood)` for the corresponding pixel. |

---

### `__spatial_filtering_range__(I, domain)`

```scilab
retval = __spatial_filtering_range__(I, domain)
```

Internal kernel that performs the sliding-window range computation over an
already-padded image `I` using structuring element `domain`.

> **Note:** This function is an implementation detail of `rangefilt`. It is not
> intended to be called directly by user code.

#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `I` | double matrix | Padded image (output of `padarray`). |
| `domain` | boolean matrix | Structuring element mask. |

#### Output

| Parameter | Type | Description |
|-----------|------|-------------|
| `retval` | double matrix | Range-filtered result with dimensions `(rows − dRows + 1) × (cols − dCols + 1)`. |

---

### `padarray(I, pad_sz, method)`

```scilab
out = padarray(I, pad_sz, method)
```

Extends image `I` by `pad_sz(1)` rows and `pad_sz(2)` columns on each side
using the specified border-extension method.

#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `I` | double matrix | Image to pad (already cast to `double`). |
| `pad_sz` | 1 × 2 integer vector | `[row_padding, col_padding]` — number of border pixels to add on each side. |
| `method` | string | Padding strategy. `"symmetric"` mirrors pixel values at each border. |

#### Output

| Parameter | Type | Description |
|-----------|------|-------------|
| `out` | double matrix | Padded image of size `(r + 2·pr) × (c + 2·pc)`. |

---

## Variable Glossary

| Variable | Scope | Description |
|----------|-------|-------------|
| `I` | input | Input image matrix |
| `domain` | input / default | Structuring element (neighbourhood mask) |
| `padding` | input / default | Border-extension method string |
| `retval` | output | Range-filtered output image |
| `lhs` | local | Number of left-hand-side (output) arguments (`argn(1)`) |
| `rhs` | local | Number of right-hand-side (input) arguments (`argn(2)`) |
| `sz_domain` | local | Size vector of `domain`: `[dRows, dCols]` |
| `pad` | local | Half-size of `domain` used as padding amount: `floor(sz_domain / 2)` |
| `even` | local | Boolean vector flagging even-sized domain dimensions |
| `r_start`, `c_start` | local | Index offsets correcting alignment for even-sized domains |
| `rows`, `cols` | local (kernel) | Dimensions of the padded image |
| `dRows`, `dCols` | local (kernel) | Dimensions of the structuring element |
| `out_rows`, `out_cols` | local (kernel) | Output dimensions: `rows − dRows + 1`, `cols − dCols + 1` |
| `initialized` | local (kernel) | Boolean flag; `%t` after the first valid domain pixel is processed |
| `max_I` | local (kernel) | Running per-pixel maximum across active neighbourhood positions |
| `min_I` | local (kernel) | Running per-pixel minimum across active neighbourhood positions |
| `window` | local (kernel) | Current spatial slice of `I` for position `(r, c)` in `domain` |
| `mask_max` | local (kernel) | Binary mask where `window > max_I`; used for branchless max update |
| `mask_min` | local (kernel) | Binary mask where `window < min_I`; used for branchless min update |
| `r`, `c` | local (kernel) | Loop indices iterating over domain rows and columns |
| `out` | output (padarray) | Padded image array |
| `pr`, `pc` | local (padarray) | Row and column padding amounts |

---

## Mathematical Definitions

### Local Range

Given an image **I** and a structuring element **D** of size *m × n*, the range
image **R** at position *(x, y)* is:

$$R(x,\, y) = \max_{(r,\,c)\,\in\,D} I(x+r,\; y+c) \;-\; \min_{(r,\,c)\,\in\,D} I(x+r,\; y+c)$$

where the max and min are taken only over positions *(r, c)* where **D(r, c) ≠ 0**.

A value of 0 at any output pixel indicates a perfectly uniform neighbourhood.

### Symmetric Padding

Before filtering, the image is extended by mirroring pixel values at each
border. For a 1-D signal of length *N* padded by *p* samples:

$$\text{out}[i] = I[\,p - 1 - i\,] \quad \text{for } 0 \le i < p \qquad (\text{left mirror})$$

$$\text{out}[p + N + j] = I[\,N - 1 - j\,] \quad \text{for } 0 \le j < p \qquad (\text{right mirror})$$

This ensures output has the same spatial dimensions as the original image and
avoids zero-valued artefacts at the boundaries.

### Even-Sized Domain Correction

When `domain` has an even number of rows or columns, a single-pixel index
offset (`r_start = 2` or `c_start = 2`) is applied after padding to re-centre
the neighbourhood correctly. This mirrors the behaviour of MATLAB's
`rangefilt` for non-standard structuring element shapes.

---

## Algorithm Explanation

```
rangefilt(I, domain, padding)
│
├─ 1. Validate inputs
│      • At least 1 argument required
│      • I must be numeric (type 1 or 8) or logical (type 4)
│      • domain must be numeric or logical; coerced to boolean
│
├─ 2. Apply defaults
│      • domain  → ones(3, 3)   if not supplied
│      • padding → "symmetric"  if not supplied
│
├─ 3. Compute padding size
│      pad = floor(size(domain) / 2)
│
├─ 4. Pad the image
│      I ← padarray(double(I), pad, padding)
│      • Casting to double prevents integer overflow during subtraction
│      • Symmetric padding mirrors border rows/columns
│
├─ 5. Correct alignment for even-sized domains
│      If domain has an even row-count: drop first row  (r_start = 2)
│      If domain has an even col-count: drop first col  (c_start = 2)
│      I ← I(r_start:$, c_start:$)
│
└─ 6. Compute range via __spatial_filtering_range__(I, domain)
       │
       ├─ For each active position (r, c) in domain where domain(r,c) ≠ 0:
       │      window = I(r : r+out_rows-1,  c : c+out_cols-1)
       │
       │      On first iteration:
       │          max_I ← window
       │          min_I ← window
       │
       │      On subsequent iterations (branchless update):
       │          mask_max = (window > max_I)
       │          max_I    = max_I·(1 − mask_max) + window·mask_max
       │
       │          mask_min = (window < min_I)
       │          min_I    = min_I·(1 − mask_min) + window·mask_min
       │
       └─ retval = max_I − min_I
```

The branchless max/min update (`mask_max` / `mask_min`) avoids per-element
`if`-statements inside the inner loop, which is important for vectorised
performance in Scilab. All intermediate arithmetic is performed in `double`
to prevent integer overflow and to preserve sub-pixel precision.

---

## Test Cases

### Test 1 — Uniform image → all zeros

```scilab
I = uint8(50 * ones(4, 4));
R = rangefilt(I);
// All pixels identical → local range = 0 everywhere
```

**Expected output:**
```
R =
  0  0  0  0
  0  0  0  0
  0  0  0  0
  0  0  0  0
```

---

### Test 2 — Step edge → non-zero at boundary

```scilab
I = [zeros(4,2), ones(4,2)];
R = rangefilt(I);
```

**Derivation:**

Along the vertical step boundary, the 3 × 3 neighbourhood spans both 0-valued
and 1-valued pixels, so the local range is 1. Pixels deep inside either flat
region have range 0.

**Expected output (interior columns, approximate):**
```
Columns in the transition zone: R ≈ 1
Columns far from the edge:      R ≈ 0
```

---

### Test 3 — Custom 2 × 2 domain

```scilab
I      = [1 2; 3 4];
domain = ones(2, 2);
R      = rangefilt(I, domain);
```

**Derivation:**
```
pad    = floor([2 2] / 2) = [1 1]
After symmetric padding (5×5 region), one output pixel is computed.
Neighbourhood = {1, 2, 3, 4}
range          = 4 − 1 = 3
```

**Expected output:**
```
R = 3
```

---

### Test 4 — Cross-shaped (non-rectangular) domain

```scilab
I      = [1  2  3;
          4  5  6;
          7  8  9];
domain = [0 1 0;
          1 1 1;
          0 1 0];
R      = rangefilt(I, domain);
```

**Derivation (centre pixel only):**
```
Active neighbours for centre pixel (2,2):
  domain positions: (1,2)→2, (2,1)→4, (2,2)→5, (2,3)→6, (3,2)→8
  max = 8,  min = 2
  range = 8 − 2 = 6
```

**Expected output (centre element):**
```
R(2,2) = 6
```

---

### Test 5 — Single-pixel image

```scilab
I = [42];
R = rangefilt(I);
```

**Derivation:**
```
After symmetric padding and a 3×3 domain of ones,
all neighbourhood values equal 42.
range = 42 − 42 = 0
```

**Expected output:**
```
R = 0
```

---

### Test 6 — Logical input

```scilab
I = [%t %f %t; %f %t %f; %t %f %t];
R = rangefilt(I);
```

**Derivation:**

Each border or corner pixel has a neighbourhood containing both `%t` (1) and
`%f` (0), giving range = 1. The centre pixel (surrounded by `%f`) will also
have range = 1.

**Expected output:**
```
All R values = 1.0  (no neighbourhood is entirely uniform)
```

---

### Test 7 — `immse` / PSNR sanity check with `rangefilt` output

```scilab
exec('psnr.sci', -1);

I   = double([10 20 30; 40 50 60; 70 80 90]);
ref = zeros(3, 3);
R   = rangefilt(I);
p   = psnr(R, ref, 255);
// Checks that range output is a valid numeric matrix compatible with psnr()
```

**Expected behaviour:**
```
psnr() returns a finite dB value — no type or size errors.
```

---

## Running the Tests

Open Scilab, navigate to the folder containing the files, then:

```scilab
exec('rangefilt.sci', -1);   // load rangefilt + helpers (suppress echo)
exec('test_rangefilt.sci');  // run all tests
```

---