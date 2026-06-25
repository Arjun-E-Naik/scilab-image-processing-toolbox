# `rangefilt.sci` — Range Filtering



---

## Overview

**Range filtering** is a non-linear spatial image processing operation that
replaces each pixel with the **local range** — the difference between the
maximum and minimum pixel values within a defined neighbourhood. It is
particularly effective for **edge and texture detection**, highlighting regions
of high local contrast while producing zero (flat) output in homogeneous areas.


---

## Calling Sequence


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
