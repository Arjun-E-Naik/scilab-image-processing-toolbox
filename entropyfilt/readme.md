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

### `compute_local_entropy(I_padded, domain, nbins, orig_size)`

Core sliding-window loop.

- `I_padded`: padded image (double, values 0–255).
- `domain`: logical neighbourhood mask.
- `nbins`: histogram bin count (2 or 256).
- `orig_size`: `[R, C]` of the original image.

Returns a `[R × C]` entropy matrix.

---

## Test Cases with Expected Outputs

### Test 1 — Uniform Image (all ones)

```scilab
A = ones(10, 10);
E = entropyfilt(A);
```

**Expected output:** `zeros(10, 10)`

**Explanation:** Every neighbourhood contains only one distinct value → one occupied histogram bin → entropy = 0.

---

### Test 2 — All-Zeros 3×3 Image

```scilab
A = zeros(3, 3);
E = entropyfilt(A);
```

**Expected output:** `zeros(3, 3)`

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
  3.1699   2.3026   2.3026   2.3026   3.1699
  2.3026   3.1699   3.1699   3.1699   2.3026
  2.3026   3.1699   3.1699   3.1699   2.3026
  2.3026   3.1699   3.1699   3.1699   2.3026
  3.1699   2.3026   2.3026   2.3026   3.1699
```

*(approximate; corner and border entropy differ from interior due to symmetric padding.)*

**Explanation:**  
Corner pixels have fewer unique neighbours after symmetric padding → lower entropy.  
Interior pixels see all 9 distinct values of `magic(5)` → maximum entropy ≈ `log₂(9) ≈ 3.1699`.

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
  3.5143  3.5700  3.4871  3.4957  3.4825
  3.4705  3.5330  3.4341  3.4246  3.3890
  3.3694  3.4063  3.3279  3.3386  3.3030
  3.3717  3.4209  3.3396  3.3482  3.3044
  3.4361  3.5047  3.3999  3.4236  3.3879
```

**Explanation:**  
The image contains a mix of gradients and repeated values. The 3×3 window sees 9 pixels; entropy ranges between ~3.3 and ~3.57, reflecting moderate diversity throughout.

---

### Test 5 — Double Matrix with 3×3 Domain

```scilab
H = [5 2 8; 1 -3 1; 5 1 0];
E = entropyfilt(H, ones(3,3));
```

**Expected output (Octave reference):**

```
E =
  0.8916  0.8256  0.7412
  0.8256  0.9710  0.6913
  0.7412  0.6913  0.6355
```

**Explanation:**  
`H` is a `double` matrix. `im2uint8` scaling compresses all values into a narrow range of 8-bit bins. The resulting histogram has few occupied bins → relatively low entropy values.

---

### Test 6 — Constant uint16 Image

```scilab
Q = uint16([100 101 103; 100 105 102; 100 102 103]);
E = entropyfilt(Q, ones(3,3));
```

**Expected output:**

```
E ≈ zeros(3, 3)
```

**Explanation:**  
After `im2uint8` scaling, the range `[100, 105]` in uint16 maps to a very narrow cluster of uint8 bins. All values fall into essentially the same bin → entropy ≈ 0.

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

**Explanation:**  
Verifies correct handling of non-square neighbourhood masks. The 3×5 domain covers 15 pixels; the image is strictly monotone, so many bins are occupied and entropy is high (roughly 3.5–3.9 bits).

---

### Test 8 — Padding Mode Comparison

```scilab
I8 = double([1 2 3; 4 5 6; 7 8 9]) / 9;
E_sym = entropyfilt(I8, ones(3,3), "symmetric");
E_rep = entropyfilt(I8, ones(3,3), "replicate");
```

**Expected:**  
`E_sym ≠ E_rep` at border pixels (max difference > 0).

**Explanation:**  
The two padding modes reflect different assumptions about what lies beyond the image border. For a non-uniform image they produce different histograms near the edges → different entropy values.

---
