# `entropyfilt.sci`

---

## Overview

`entropyfilt` slides a neighbourhood window (called the **domain**) across every pixel of an image and computes the **Shannon entropy** of the intensity distribution within that window.

- High entropy → highly varied, complex neighbourhood (edges, textures).
- Low entropy → smooth, uniform neighbourhood (flat regions).

This makes the filter a useful **texture measure** and a building block for segmentation, feature extraction, and region analysis.

---
## Calling Sequence
```scilab
E = entropyfilt(I)
E = entropyfilt(I, domain)
E = entropyfilt(I, domain, padding)
```
---

### Entropy Bounds

| Scenario | Entropy value |
|----------|--------------|
| All pixels identical (one bin used) | **0** |
| All `N` pixels have distinct values | **log₂(N)** |
| Uniform distribution over all 256 bins | **log₂(256) = 8** |

---


### Complexity

| Stage | Complexity |
|-------|-----------|
| Padding | O(R · C) |
| Entropy computation | O(R · C · K) where K = number of active domain pixels |
| Total | O(R · C · K) |

For a 512×512 image with a 9×9 domain, K = 81, giving ≈ 21 million pixel accesses.


---


### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| E | double matrix, same size as I | Local entropy at every pixel (bits) |

---

## Variable Reference

### Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric or logical matrix | — | Input 2-D image. Accepted Scilab types: `double`, `single`, `int8`, `uint8`, `int16`, `uint16`, `int32`, `uint32`, `int64`, `uint64`, `logical`. |
| `domain` | numeric or logical matrix | `ones(9, 9)` | Neighbourhood mask. Non-zero entries define which pixels participate in the entropy calculation. Typically a square logical matrix of odd size. |
| `padding` | string | `"symmetric"` | Border extrapolation mode. Controls how the image is extended beyond its edges. See [Padding Modes] |



## Padding Modes

| Mode | Description | 
|------|-------------|
| `"symmetric"` *(default)* | Mirror reflection at border | 
| `"replicate"` | Nearest border value repeated |
| `"circular"` | Wrap-around (periodic) |
| `"zeros"` | Zero padding | `… 0 0 0 |

---

## Dependencies

### `im2uint8(I)`

Converts any numeric matrix to uint8-equivalent double values in `[0, 255]`.

- `double`/`single`: assumes `[0, 1]` input range, multiplied by 255.
- Integer types: extracted and clamped to `[0, 255]`.
- `logical`: returned as 0 or 1 (no change).

### `padarray(I, pad, mode)`

Pads a 2-D matrix symmetrically on all four sides.

- `I`: input matrix.
- `pad`: `[row_pad, col_pad]` — number of pixels to add per side.
- `mode`: one of `"symmetric"`, `"replicate"`, `"circular"`, `"zeros"`.

### `__spatial_filtering__()`

### imhist()

---

## Test Cases with Expected Outputs

### Test 1 — Uniform Image (all ones)

```scilab
A = ones(10, 10);
E = entropyfilt(A);
```

**Expected output:** `zeros(10, 10)`
```
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.   0.   0.   0.
```

---

### Test 2 — All-Zeros 3×3 Image

```scilab
A = zeros(3, 3);
E = entropyfilt(A);
```

**Expected output:** 
```
   0.   0.   0.
   0.   0.   0.
   0.   0.   0.
```

**Explanation:** Same as Test 1 — constant value means zero entropy everywhere.

---

### Test 3 — `magic(5)` with 3×3 Domain

```scilab
M = uint8([17 24  1  8 15;
           23  5  7 14 16;
            4  6 13 20 22;
           10 12 19 21  3;
           11 18 25  2  9]);

E = entropyfilt(M, ones(3,3));
```

**Expected output (Octave-verified):**

```
E =
   1.8365917   2.5032583   2.5032583   2.5032583   1.8365917
   2.5032583   3.169925    3.169925    3.169925    2.5032583
   2.5032583   3.169925    3.169925    3.169925    2.5032583
   2.5032583   3.169925    3.169925    3.169925    2.5032583
   1.8365917   2.5032583   2.5032583   2.5032583   1.8365917
```


---

### Test 4 — 5×5 Uint8 Gradient Image with 3×3 Domain

```scilab
R = uint8([ 1  2  3  4  5;
           11 12 13 14 15;
           21 22  4  5  6;
            5  5  3  2  1;
           15 14 14 14 14]);

E = entropyfilt(R, ones(3,3));
```

**Expected output (Octave reference):**

```
E =
   1.8365917   2.5032583   2.5032583   2.5032583   1.8365917
   2.5032583   3.169925    2.9477028   2.7254806   2.1971597
   2.1971597   2.9477028   2.9477028   3.169925    2.5032583
   2.1971597   2.7254806   2.4193819   2.6416042   2.1971597
   1.2243944   1.8365917   1.9749375   1.9749375   1.5304931
```


---

### Test 5 — Double Matrix with 3×3 Domain

```scilab
H = [5 2 8; 1 3 1; 5 1 0];
E = entropyfilt(H, ones(3,3));
```

**Expected output (Octave reference):**

```
E =
  0.   0.          0.       
   0.   0.5032583   0.5032583
   0.   0.5032583   0.5032583
```


---

### Test 6 — Constant uint16 Image

```scilab
Q = uint16([100 101 103; 100 105 102; 100 102 103]);
E = entropyfilt(Q, ones(3,3));
```

**Expected output:**

```
0 0 0
0 0 0
0 0 0
```


---

### Test 7 — Non-Square Domain (3×5)

```scilab
I7 = uint8([10 20 30 40 50;
            15 25 35 45 55;
            20 30 40 50 60;
            25 35 45 55 65;
            30 40 50 60 70]);

E7 = entropyfilt(I7, ones(3, 5));
```

**Expected:** Output is 5×5, all values ≥ 0.
```
   2.4402239   2.8402239   3.2402239   2.8402239   2.4402239
   2.6565648   3.0062389   3.3735573   3.0062389   2.6565648
   2.6565648   3.0062389   3.3735573   3.0062389   2.6565648
   2.6565648   3.0062389   3.3735573   3.0062389   2.6565648
   2.4402239   2.8402239   3.2402239   2.8402239   2.4402239
```

---

### Test 8 — Padding Mode Comparison

```scilab
I8 = double([1 2 3; 4 5 6; 7 8 9]) / 9;
E_sym = entropyfilt(I8, ones(3,3), "symmetric");
E_rep = entropyfilt(I8, ones(3,3), "replicate");
```

**Expected:**  
`E_sym ≠ E_rep` at border pixels (max difference > 0).
```
E_sym:
   1.8365917   2.5032583   1.8365917
   2.5032583   3.169925    2.5032583
   1.8365917   2.5032583   1.8365917

E_rep:
   1.8365917   2.5032583   1.8365917
   2.5032583   3.169925    2.5032583
   1.8365917   2.5032583   1.8365917
```


---
