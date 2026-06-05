# entropy.sci 
 
---

 
## Overview
 
**Shannon entropy** measures the amount of information (or randomness/disorder) present in an image. A uniform, single-colour image carries zero entropy; a noisy image with pixel values spread evenly across all intensities carries maximum entropy.
 
`entropy.sci` computes this quantity by:
 
1. Converting the image to an 8-bit (0–255) integer representation.  
2. Building a histogram of pixel intensities.  
3. Normalising the histogram into a probability distribution **P**.  
4. Applying the Shannon entropy formula **E = −Σ P · log₂(P)**.
The result is expressed in **bits**.
 
---
 

 
## entropy()
 
```scilab
// Load the function
exec('entropy.sci', -1)
 
// Compute entropy of a grayscale image matrix
I = [0 128 64; 200 0 255; 100 50 180];
E = entropy(I)
// E ≈ 2.75 bits  (varies with exact distribution)
 
// Run the full test suite
exec('test_entropy.sci', -1)
```
 
---
 
 
### `entropy()`
 
```
E = entropy(I)
E = entropy(I, nbins)
```
 
**Computes the Shannon entropy of an image.**
 
#### Parameters
 
| Parameter | Type | Description |
|-----------|------|-------------|
| `I` | real numeric or logical array (any shape) | The input image. May be 2-D (grayscale) or n-D (e.g. RGB as a 3-D array). All elements are pooled into a single flat list of pixel values. |
| `nbins` | positive integer scalar *(optional)* | Number of histogram bins used to estimate the probability distribution. Default: **2** for logical arrays, **256** for all other types. |
 
#### Return Value
 
| Variable | Type | Description |
|----------|------|-------------|
| `E` | scalar double | Shannon entropy in **bits**. Range: `[0, log2(nbins)]`. |
 
 
### `im2uint8()` —  helper function
 
```
out = im2uint8(I)
```
 
Converts a numeric image array to uint8-equivalent double values (range 0–255), mirroring Octave/Matlab `im2uint8` semantics.
 
| Input value range | Conversion applied |
|-------------------|--------------------|
| `[0.0, 1.0]` (floating-point image) | Scaled: `round(I × 255)` |
| Outside `[0, 255]` (integer-coded) | Clamped to `[0, 255]` then rounded |
 

 
---
 
### `imhist_scilab()` — helper function
 
```
counts = imhist_scilab(I, nbins)
```
 
Computes a histogram of pixel values over `nbins` equally-spaced bins, replicating the behaviour of Octave's `imhist()`.
 
| Parameter | Description |
|-----------|-------------|
| `I` | Column vector of pixel values (doubles, range 0–255) |
| `nbins` | Number of bins (`2` for logical, `256` otherwise) |
| **Returns `counts`** | `nbins × 1` vector of integer bin counts |
 
For binary/logical images (`nbins = 2`): bin 1 = value 0, bin 2 = any non-zero value.  
For uint8 images (`nbins = 256`): bins are uniformly spaced over `[0, 255]`.
 
---
 
## Variable Reference
 
The following variables are in `entropy()` and its helpers:
 
| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `I` | input | double / logical array | Input image (any shape). |
| `nbins` | input / local | integer scalar | Number of histogram bins. Set to `0` as a sentinel on entry; resolved to `2` or `256` before use. |
| `E` | output | scalar double | Computed Shannon entropy in bits. |
| `pixels` | local | column vector | Flattened version of `I` after type conversion (`I(:)`). |
| `P` | local | column vector | Histogram counts, then (after zero-removal) normalised probabilities. |
| `bin_width` | local (helper) | scalar double | Width of each histogram bin: `255 / (nbins − 1)`. |
| `lo`, `hi` | local (helper) | scalar double | Lower and upper edges of the current histogram bin during the counting loop. |
| `out` | local (im2uint8) | double array | uint8-range image values returned by `im2uint8`. |
| `counts` | local (imhist) | column vector | Raw bin counts returned by `imhist_scilab`. |
| `lhs`, `rhs` | local | integers | Number of left-hand / right-hand side arguments, obtained via `argn(0)`. |
 
---
 
## Algorithm Explanation
 
```
Input image I
      │
      ▼
┌─────────────────────────────────────────────────────┐
│  1. Validate inputs                                  │
│     – Must be real, numeric or logical               │
│     – nbins must be a scalar (> 0)                   │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  2. Choose default nbins                             │
│     – logical image → 2                              │
│     – any other type → 256                           │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  3. Type conversion  (non-logical images only)       │
│     im2uint8(I)                                      │
│     – float [0,1] → round(I × 255)                  │
│     – integer-coded → clamp to [0,255]               │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  4. Flatten to column vector  pixels = I(:)          │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  5. Build histogram  P = imhist_scilab(pixels, nbins)│
│     – nbins equally-spaced bins over [0, 255]        │
│     – logical: bin1 = zeros, bin2 = non-zeros        │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  6. Remove zero-count bins  P(P == 0) = []           │
│     (avoids 0·log2(0) = NaN / −Inf)                  │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  7. Normalise  P = P / sum(P)                        │
│     → P is now a probability distribution            │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  8. Compute entropy  E = −sum(P .* log2(P))          │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
                  Return E
```
 
**Complexity:** O(N) where N is the total number of pixels (for building the histogram). The normalisation and entropy summation are O(nbins) ≤ O(256).
 
---
 
## Mathematical Foundation
 
### Shannon Entropy
 
Given a discrete random variable X with probability mass function P(xᵢ), Shannon entropy is defined as:
 
```
        K
E = −  Σ  P(xᵢ) · log₂ P(xᵢ)
       i=1
```
 
where the sum runs over all **non-zero** probability values. The unit is **bits** (base-2 logarithm).
 
### Estimation via Histogram
 
The true distribution P is unknown; it is estimated from the image using a histogram:
 
```
           count of pixels in bin i
P(xᵢ) =  ─────────────────────────
              total pixel count
```
 
### Boundary Values
 
| Condition | Entropy |
|-----------|---------|
| All pixels identical (1 occupied bin) | **0 bits** — no uncertainty |
| Pixels uniformly distributed over all K bins | **log₂(K) bits** — maximum uncertainty |
| Binary image, equal 0s and 1s | **1 bit** |
 
### Handling 0 · log₂(0)
 
By convention, 0 · log₂(0) = 0 (the limit as p → 0⁺ of p · log₂ p is 0). The code enforces this by **deleting zero-count bins** before computing the sum, avoiding undefined arithmetic.
 
### im2uint8 Scaling
 
For a floating-point image I ∈ [0, 1]:
 
```
I_uint8(i,j) = round( I(i,j) × 255 )
```
 
This maps the continuous range to 256 integer levels, giving a consistent 256-bin histogram regardless of the original floating-point precision.
 
---
 
## Test Cases with Expected Outputs
 
### Test 1 — Binary double array `[0, 1]`
 
```scilab
E = entropy([0, 1])
```
 
**Distribution:** P = [0.5, 0.5]  
**Calculation:** E = −(0.5 · log₂0.5 + 0.5 · log₂0.5) = −(−0.5 − 0.5) = **1.0 bit**  
**Expected output:** `E = 1.`
 
---
 
### Test 2 — Constant array `[0, 0]`
 
```scilab
E = entropy([0, 0])
```
 
**Distribution:** All pixels identical → only one occupied bin, P = [1.0]  
**Calculation:** E = −(1.0 · log₂1.0) = 0  
**Expected output:** `E = 0.`
 
---
 
### Test 3 — Single element `[1]`
 
```scilab
E = entropy([1])
```
 
**Distribution:** P = [1.0]  
**Calculation:** E = 0 (only one possible value)  
**Expected output:** `E = 0.`
 
---
 
### Test 4 — 3×3 logical array (mixed true/false)
 
```scilab
L = [%f %t %t; %f %t %t; %f %f %t]   // 5 false, 4 true
E = entropy(L)
```
 
**Distribution:** P = [5/9, 4/9]  
**Calculation:**
 
```
E = −(5/9 · log₂(5/9) + 4/9 · log₂(4/9))
  = −(5/9 · (−0.84799) + 4/9 · (−1.16993))
  ≈ 0.9911 bits
```
 
**Expected output:** `E ≈ 0.9910761`
 
---
 
### Test 5 — Uniform 3×3 uint8 matrix (all 128)
 
```scilab
U = 128 .* ones(3, 3)
E = entropy(U)
```
 
**Distribution:** All 9 pixels map to the same bin → P = [1.0]  
**Calculation:** E = 0  
**Expected output:** `E = 0.`
 
---
 
### Test 6 — 3×3 matrix `C = [1 1 1; 2 2 2; 3 3 3]`
 
```scilab
C = [1 1 1; 2 2 2; 3 3 3]
E = entropy(C)
```
 
 
**Expected output:** `E = 0`
 

---
