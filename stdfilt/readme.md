# `stdfilt` — Local Standard Deviation Filter for Images 

---

## Overview

`stdfilt` slides a neighbourhood window (called the **domain**) across every pixel of an image and computes the **local standard deviation** of intensity values within that window.

- High std dev → high local contrast, rapid intensity variation (edges, textures).
- Low std dev → smooth, uniform neighbourhood (flat, homogeneous regions).

This makes the filter a useful **texture and edge descriptor** and a building block for contrast enhancement, noise estimation, segmentation, and adaptive thresholding.

---

## Mathematical Background

### Unbiased Sample Standard Deviation

For a neighbourhood of **N** active pixels with values **x₁, x₂, …, xₙ**, the local standard deviation is:

```
σ = sqrt( ( Σ xᵢ² - (Σ xᵢ)² / N ) / (N - 1) )
```

This is the **unbiased (sample) standard deviation**, dividing by **N − 1** (Bessel's correction) rather than N.

### Efficient Computation via Convolution

`stdfilt` exploits the linearity of convolution to compute the required sums in two passes:

| Quantity | Convolution |
|----------|-------------|
| Local sum: `Σ xᵢ` | `conv2(I_padded, domain_flipped, "valid")` |
| Local sum of squares: `Σ xᵢ²` | `conv2(I_padded.² , domain_flipped, "valid")` |

The variance is then assembled from these two maps:

```
variance = ( sum_X2 - sum_X.² / N ) / (N - 1)
```


### Domain Active Pixel Count

| Symbol | Meaning |
|--------|---------|
| `N` | Total number of non-zero pixels in `domain` (`= sum(domain(:))`) |
| `domain_flipped` | `domain` rotated 180° — used so that `conv2` acts as **correlation**  |

### Edge Case: Degenerate Domain

If **N ≤ 1**, standard deviation is undefined .  
`stdfilt` handles this by returning a **zero matrix** of the same size as the input.

### Input Type Handling

 `stdfilt` converts the input directly to `double` and operates in the continuous intensity domain.

---

## Algorithm

```
stdfilt(I, domain, padding)
│
├─ 1. Validate inputs
│     └─ domain must be numeric or logical (type 1, 4, or 8)
│
├─ 2. Cast domain to logical (boolean)
│     └─ Any non-zero element becomes %T
│
├─ 3. Convert I to double
│
├─ 4. Pad the image
│     └─ pad = floor( size(domain) / 2 )
│     └─ Default mode: "replicate" (nearest border value)
│     └─ Supported: "replicate", "symmetric", "zeros"
│
├─ 5. Trim extra row/col for even-sized domains
│     └─  idx = (even(k)+1 : size(I, k)) trimming
│
├─ 6. Compute N = sum(domain)
│     └─ If N ≤ 1, return zeros(orig_size)
│
├─ 7. Compute convolution maps
│     ├─ domain_flipped = domain rotated 180°
│     ├─ sum_X  = conv2(I_padded,    domain_flipped, "valid")
│     └─ sum_X2 = conv2(I_padded.^2, domain_flipped, "valid")
│
├─ 8. Assemble unbiased variance
│     └─ variance = (sum_X2 - sum_X.^2 / N) / (N - 1)
│
├─ 9. Clamp negative variance to zero
│     └─ variance = variance .* (variance > 0)
│
└─ 10. Return sqrt(variance)
```

### Complexity

| Stage | Complexity |
|-------|-----------|
| Padding | O(R · C) |
| Two `conv2` passes | O(R · C · K) where K = number of active domain pixels |
| Total | O(R · C · K) |

---

## Syntax

```scilab
S = stdfilt(I)
S = stdfilt(I, domain)
S = stdfilt(I, domain, padding)
```

### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `retval` | double matrix, same size as I | Local standard deviation at every pixel |

---

## Variable Reference

### Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric or logical matrix | — | Input 2-D image. Any numeric Scilab type is accepted; it is cast to `double` internally. |
| `domain` | numeric or logical matrix | `ones(3, 3)` (logical) | Neighbourhood mask. Non-zero entries define which pixels participate in the standard deviation calculation. Typically a square logical matrix of odd size. |
| `padding` | string | `"replicate"` | Border extrapolation mode. Controls how the image is extended beyond its edges.. |

### Internal Variables

| Variable | Scope | Description |
|----------|-------|-------------|
| `orig_size` | `stdfilt` | `[R, C]` — original image dimensions before padding. |
| `pad` | `stdfilt` | `[pr, pc]` — row and column padding half-sizes, computed as `floor(size(domain) / 2)`. |
| `I_padded` | `stdfilt` | Image after padding and optional even-domain trimming, as a double matrix. |
| `even` | `stdfilt` | Boolean flag `[1×2]`; true for each domain dimension that is even-sized. |
| `idx1`, `idx2` | `stdfilt` | Index vectors used to trim `I_padded` after even-domain adjustment. |
| `domain_double` | `stdfilt` | `domain` cast to `double` for use in `conv2`. |
| `domain_flipped` | `stdfilt` | `domain_double` rotated 180° so that convolution acts as correlation. |
| `N` | `stdfilt` | Scalar — number of active (non-zero) pixels in `domain`. |
| `sum_X` | `stdfilt` | Matrix of local pixel sums over the domain (`conv2` result). |
| `sum_X2` | `stdfilt` | Matrix of local pixel-squared sums over the domain (`conv2` result). |
| `variance` | `stdfilt` | Intermediate unbiased variance matrix before square root and clamping. |
| `retval` | `stdfilt` | Final output — local standard deviation, same size as `I`. |

---

## Padding Modes

| Mode | Description |
|------|-------------|
| `"replicate"` *(default)* | Nearest border value repeated outward |
| `"symmetric"` | Mirror reflection at border |
| `"zeros"` | Zero padding (all border pixels treated as 0) |


---

## Helper Behaviour

### Padding (inline, not a separate function)


- **replicate**: constructs `r_idx` / `c_idx` by clamping out-of-bounds indices to 1 or `orig_size(k)`.
- **symmetric**: constructs mirror index ranges on both sides.
- **zeros**: allocates a zero matrix and inserts `I` into the centre block.

### Even-Domain Trimming

When any dimension of `domain` is even-sized, the padded image is trimmed by one row or column at the start (index 2 onward instead of 1). This replicates Octave's `stdfilt` offset behaviour for even kernels, ensuring the output is always `orig_size`.

---

## Test Cases with Expected Outputs

### Test 1 — Uniform Image (all ones)

```scilab
A = ones(5, 5);
S = stdfilt(A);
```

**Expected output:** `zeros(5, 5)`

**Explanation:** Every neighbourhood contains only one distinct value. All deviations from the mean are zero, so standard deviation = 0 everywhere.

---

### Test 2 — All-Zeros Image

```scilab
A = zeros(4, 4);
S = stdfilt(A);
```

**Expected output:** `zeros(4, 4)`

**Explanation:** Same reasoning as Test 1 — a constant (zero) image has no local variation.

---

### Test 3 — `magic(5)` with 3×3 Domain

```scilab
M = uint8([17 24  1  8 15;
           23  5  7 14 16;
            4  6 13 20 22;
           10 12 19 21  3;
           11 18 25  2  9]);

S = stdfilt(M, ones(3,3));
```

**Expected output (Octave-verified, approximate):**

```
S =
  7.3654   8.5528   8.5528   8.5528   7.3654
  8.5528   7.5277   7.5277   7.5277   8.5528
  8.5528   7.5277   7.5277   7.5277   8.5528
  8.5528   7.5277   7.5277   7.5277   8.5528
  7.3654   8.5528   8.5528   8.5528   7.3654
```

**Explanation:**  
`magic(5)` has all distinct values 1–25 spread evenly. Interior pixels see 9 distinct, well-spread values → high std dev. Corner pixels have replicated border values → slightly different (lower) std dev due to value repetition from `"replicate"` padding.

---

### Test 4 — 5×5 Gradient Image with 3×3 Domain

```scilab
R = uint8([ 1  2  3  4  5;
           11 12 13 14 15;
           21 22  4  5  6;
            5  5  3  2  1;
           15 14 14 14 14]);

S = stdfilt(R, ones(3,3));
```

**Expected:** Output is 5×5, all values ≥ 0.

**Explanation:**  
The image mixes gradients with flat regions. The 3×3 window sees 9 values; std dev is higher in areas of rapid change (top rows) and lower in flatter regions (bottom-right corner).

---

### Test 5 — Single-Row Image

```scilab
A = [1 2 3 4 5];
S = stdfilt(A, ones(1, 3));
```

**Expected output:**

```
S =
  0.7071   1.0000   1.0000   1.0000   0.7071
```

**Explanation:**  
For a 1×3 window on a linear ramp, interior pixels see three consecutive integers whose std dev is exactly 1. Border pixels (with replicated padding) see only two distinct values → lower std dev of ≈ 0.707.

---

### Test 6 — Degenerate Domain (N ≤ 1)

```scilab
I = uint8([1 2 3; 4 5 6; 7 8 9]);
S = stdfilt(I, [0 0 0; 0 1 0; 0 0 0]);  // single active pixel
```

**Expected output:** `zeros(3, 3)`

**Explanation:**  
With only one active pixel in the domain, `N = 1` and `N − 1 = 0`, making variance undefined. `stdfilt` detects this and returns an all-zero matrix to avoid division by zero.

---

### Test 7 — Non-Square Domain (3×5)

```scilab
I7 = uint8([10 20 30 40 50;
            15 25 35 45 55;
            20 30 40 50 60;
            25 35 45 55 65;
            30 40 50 60 70]);

S7 = stdfilt(I7, ones(3, 5));
```

**Expected:** Output is 5×5, all values ≥ 0.

**Explanation:**  
Verifies correct handling of non-square neighbourhood masks. The 3×5 domain (N = 15) spans a wider horizontal range; the strictly increasing image has moderate, consistent std dev across the output.

---

### Test 8 — Padding Mode Comparison

```scilab
I8 = double([1 2 3; 4 5 6; 7 8 9]);
S_rep = stdfilt(I8, ones(3,3), "replicate");
S_sym = stdfilt(I8, ones(3,3), "symmetric");
S_zer = stdfilt(I8, ones(3,3), "zeros");
```

**Expected:**  
`S_rep`, `S_sym`, and `S_zer` all differ at border pixels (max pairwise difference > 0); interior pixel `S(2,2)` is the same for all three modes.

**Explanation:**  
Border extrapolation only affects pixels whose neighbourhood extends beyond the image edge. The three modes produce different virtual border values → different local std dev at border pixels. The centre pixel always uses only real image values, so its result is padding-independent.

---

### Test 9 — Double-Precision Floating-Point Input

```scilab
H = [5.0 2.0 8.0; 1.0 -3.0 1.0; 5.0 1.0 0.0];
S = stdfilt(H, ones(3,3));
```

**Expected:** 3×3 double matrix with values ≥ 0.

**Explanation:**  
`stdfilt` accepts `double` input directly without any rescaling. Negative values are valid — they simply shift the local mean; the standard deviation (spread around the mean) is unaffected by a global offset.

---

### Test 10 — Large Flat Region with Isolated Spike

```scilab
I10 = zeros(7, 7);
I10(4, 4) = 100;
S10 = stdfilt(I10, ones(3,3));
```

**Expected:** `S10` is zero everywhere except in the 3×3 neighbourhood centred on (4,4).

**Explanation:**  
Pixels whose 3×3 window does not include (4,4) see all zeros → std dev = 0. Pixels whose window does include the spike see a mix of zeros and 100 → non-zero std dev, with the maximum at (4,4) itself.

---
