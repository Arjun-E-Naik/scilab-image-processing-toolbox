# applylut.sci — Neighbourhood Look-Up Table Application for Scilab

---

## Overview

`applylut` applies a **neighbourhood look-up table (LUT)** to a binary image. For every pixel in the image it examines the pixel's neighbourhood, converts that neighbourhood into an integer index, and replaces the pixel's output value with the entry at that index in the LUT.

 The translation is non-trivial because Octave and Scilab have fundamentally different conventions for how matrices are laid out in memory and how convolution kernels are applied  both of which directly affect which LUT entry gets selected for each pixel.


---

## Quick Start

```scilab
// Load the function
exec('applylut.sci', -1)

// Apply a simple all-ones LUT to a 3x3 all-true image
LUT = zeros(512, 1);
LUT(512) = 1;
BW  = ones(3, 3) == 1;
A   = applylut(BW, LUT)
// Only the centre pixel (surrounded on all sides) reaches index 512
//  A = [0 0 0; 0 1 0; 0 0 0]

// Run the full test suite
exec('test_applylut.sci', -1)
```

---

## Function Reference

### `applylut()`

```
A = applylut(BW, LUT)
```

**Applies a look-up table to every pixel of a binary image based on its 3 × 3 neighbourhood.**

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `BW` | logical matrix (any size ≥ 3 × 3) | The input binary image. Logical `%t`/`%f` values; `bool2s` is applied internally before convolution. |
| `LUT` | numeric column vector of length 512 | The look-up table. Entry `k` (1-indexed) is the output value assigned when a neighbourhood maps to index `k − 1`. Must have exactly 512 entries (2⁹ neighbourhoods for a 3 × 3 window). |

#### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `A` | double matrix, same size as `BW` | Output image. Each pixel holds the LUT value selected by its neighbourhood index. Border pixels are zero-padded (see [Border Behaviour](#border-behaviour)). |

#### Error Conditions

| Condition | Error message |
|-----------|---------------|
| Fewer or more than 2 arguments supplied | `"Arguments must be Two.."` |
| `LUT` length is not an exact power of 4 (i.e. `log₂(length)` is not a perfect square) | `"applylut: LUT length is not as expected."` |

---

### `filter2()` — companion helper

```
y = filter2(b, x)
y = filter2(b, x, shape)
```

Replicates Octave's `filter2` using Scilab's `conv2`. Octave's `filter2(b, x)` performs **correlation** (no kernel flip), whereas Scilab's `conv2(x, b)` performs **true convolution** (flips the kernel). This helper compensates by pre-flipping `b` before passing it to `conv2`, so the net result is correlation .

| Parameter | Type | Description |
|-----------|------|-------------|
| `b` | numeric matrix | The filter kernel (applied via correlation). |
| `x` | numeric matrix | The signal/image to filter. |
| `shape` | string *(optional)* | Output size: `"same"` (default), `"full"`, or `"valid"`. Passed directly to `conv2`. |

**Returns `y`:** filtered matrix of the size determined by `shape`.

---

## Variable Reference

The following variables appear inside `applylut` and `filter2`:

| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `BW` | input | logical matrix | Binary input image. |
| `LUT` | input | double column vector (512 × 1) | Look-up table mapping neighbourhood indices to output values. |
| `A` | output | double matrix | Result image; same dimensions as `BW`. |
| `lhs`, `rhs` | local | integers | Left-hand and right-hand argument counts from `argn(0)`, used for input validation. |
| `nq` | local | scalar double | Total number of neighbourhood bits: `log₂(length(LUT))`. For a standard 512-entry LUT, `nq = 9`. |
| `n` | local | scalar double | Neighbourhood side length: `√nq`. For `nq = 9`, `n = 3` (a 3 × 3 window). |
| `w` | local | n × n double matrix | Weight matrix filled column-major from the powers-of-2 sequence `2⁰, 2¹, …, 2^(nq−1)`. Encodes which bit position each neighbourhood cell contributes. |
| `w_flipped` | local | n × n double matrix | `w` rotated 180°: `w(n:-1:1, n:-1:1)`. Passed to `filter2` so that after `conv2`'s internal flip the effective weights match Octave's indexing. |
| `idx` | local | double matrix | Raw neighbourhood indices (0-based) computed by `filter2`. Each entry is the integer formed by summing the weights of the `%t` pixels in the corresponding neighbourhood. |
| `b` | input (`filter2`) | numeric matrix | Kernel passed to `filter2`; pre-flipped before being handed to `conv2`. |
| `x` | input (`filter2`) | numeric matrix | Image or signal to be filtered. |
| `shape` | input (`filter2`) | string | Convolution output shape; default `"same"`. |
| `nr`, `nc` | local (`filter2`) | integers | Row and column count of the kernel `b`, used to construct the flip range. |
| `y` | output (`filter2`) | double matrix | Filtered result from `conv2`. |

---

## The Column-Major vs Row-Major Problem

This is the most important porting challenge. Understanding it is essential for anyone verifying, extending, or debugging this code.

### How Octave assigns neighbourhood bit positions

Octave's `applylut` scans a 3 × 3 neighbourhood and assigns a power of 2 to each cell following **column-major (Fortran) order** — it moves down each column before moving to the next column:

```
Octave effective bit weights (column-major fill):
┌─────┬─────┬─────┐
│  1  │  8  │ 64  │
│  2  │ 16  │ 128 │
│  4  │ 32  │ 256 │
└─────┴─────┴─────┘
```

The centre pixel (position 5 in column-major order) receives weight **2⁴ = 16**.

### How Scilab fills a matrix

Scilab is also column-major, so the following call fills identically:

```scilab
w = matrix(2 .^ [0:8], 3, 3);
```

This produces:

```
w (as filled by Scilab matrix()):
┌─────┬─────┬─────┐
│  1  │  8  │ 64  │
│  2  │ 16  │ 128 │
│  4  │ 32  │ 256 │
└─────┴─────┴─────┘
```



### How conv2 changes the picture

Scilab's `conv2(x, b)` implements **true convolution**: it flips the kernel `b` by 180° before sliding it over `x`. Octave's `filter2(b, x)` implements **correlation**: no flip. These are related by:

```
conv2(x, b)  ≡  filter2(b_flipped, x)
filter2(b, x) ≡  conv2(x, b_flipped)
```

If the weight matrix `w` is passed directly to `conv2`, the kernel gets flipped internally and the wrong weights land on the wrong neighbours. A pixel that should contribute weight 1 (top-left) would instead contribute weight 256 (bottom-right), producing a completely different index — and therefore a completely different LUT entry.

###  pre-flip w

The solution is to hand `conv2` an already-flipped version of `w`. When `conv2` flips it again, the double flip cancels out and the effective weights match Octave's column-major assignment:

```scilab
w_flipped = w(n:-1:1, n:-1:1);   // flip w by 180°
idx = filter2(w_flipped, bool2s(BW));
```

Inside `filter2`, `w_flipped` is flipped once more before being passed to `conv2`, giving a net of **two flips = no flip**, and the final effective weights are:

```
Effective weights after double-flip (what conv2 actually applies):
┌─────┬─────┬─────┐
│  1  │  8  │ 64  │
│  2  │ 16  │ 128 │
│  4  │ 32  │ 256 │
└─────┴─────┴─────┘
```

This matches Octave exactly.

### Summary

| Step | What happens |
|------|-------------|
| `matrix(2.^[0:8], 3, 3)` | Creates `w` with column-major bit weights — matches Octave  |
| Pass `w` directly to `conv2` | `conv2` flips `w` internally → wrong weights  |
| Pre-flip `w` → `w_flipped` | Cancels `conv2`'s internal flip → correct weights  |
| `filter2` flips its input before calling `conv2` | Encapsulates the correction so callers pass natural kernels |


---

## Algorithm Walkthrough

```
Input: BW (logical matrix), LUT (512 × 1 vector)
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│  1. Validate arguments                                    │
│     – Exactly 2 arguments required                       │
│     – length(LUT) must satisfy: √(log₂(length)) ∈ ℤ     │
└───────────────────────────┬──────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│  2. Compute neighbourhood size                            │
│     nq = log₂(length(LUT)) = 9 (normally)                           │
│     n  = √nq               = 3  (normally)                         │
└───────────────────────────┬──────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│  3. Build weight matrix    │
│     w = matrix(2.^[0:nq-1], n, n)                        │
│       ┌─────┬─────┬─────┐                               │
│       │  1  │  8  │ 64  │                               │
│       │  2  │ 16  │ 128 │                               │
│       │  4  │ 32  │ 256 │                               │
│       └─────┴─────┴─────┘                               │
└───────────────────────────┬──────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│  4. Pre-flip to compensate for conv2's internal flip      │
│     w_flipped = w(n:-1:1, n:-1:1)                        │
└───────────────────────────┬──────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│  5. Compute neighbourhood indices via filter2             │
│     idx = filter2(w_flipped, bool2s(BW))                 │
│     – filter2 pre-flips its kernel, then calls conv2      │
│     – Net effect: double flip = identity → correct index  │
│     – idx(i,j) ∈ [0, 511] for a 3×3 neighbourhood        │
└───────────────────────────┬──────────────────────────────┘
                            │
┌──────────────────────────────────────────────────────────┐
│  6. Map indices to LUT entries (1-based offset)           │
│     A = matrix(LUT(idx(:) + 1), size(idx,1), size(idx,2))│
│     – idx+1 converts 0-based index to 1-based LUT offset │
└───────────────────────────┬──────────────────────────────┘
                            │
                            ▼
                         Return A
```

**Complexity:** O(M × N) where M × N is the image size. The convolution step dominates; LUT lookup is O(M × N) afterwards.

---

## Standard LUT Definitions

The test suite and typical usage rely on a small set of standard LUTs. All are vectors of length 512 (indices 0–511, stored 1-indexed in Scilab):

| LUT name | Construction | Effect |
|----------|-------------|--------|
| `LUT_ones` | `zeros(512,1); LUT(512) = 1` | Output `1` only when all 9 neighbours are `1` (index 511 = all bits set). |
| `LUT_inv` | `ones(512,1); LUT(512) = 0` | Output `1` everywhere *except* when all 9 neighbours are `1`. Logical inverse of `LUT_ones`. |
| `LUT_center` | `zeros(512,1); LUT(17) = 1` | Output `1` only when the centre pixel alone is `1` (index 16 = bit 4 = weight 16). |
| `LUT_line` | `zeros(512,1); LUT(147) = 1` | Output `1` for one specific neighbourhood pattern (index 146, middle row of a 4-row block). |

---

## Test Cases with Expected Outputs

### Test 1 — Alternating 3 × 3 matrix, `LUT_ones`

```scilab
BW1 = [%f, %t, %f; %t, %f, %t; %f, %t, %f];
disp(applylut(BW1, LUT_ones));
```

No pixel has all nine neighbours set to `1`, so no index reaches 511.

**Expected output:** all zeros (3 × 3 matrix of `0`).

---

### Test 2 — All-ones 3 × 3 matrix, `LUT_ones`

```scilab
BW2 = ones(3, 3) == 1;
disp(applylut(BW2, LUT_ones));
```

Only the centre pixel has all nine neighbours equal to `1` (the border pixels are zero-padded). Index 511 is reached only at position (2,2).

**Expected output:**
```
0  0  0
0  1  0
0  0  0
```

---

### Test 3 — All-zeros 4 × 5 matrix, `LUT_ones`

```scilab
BW3 = zeros(4, 5) == 1;
disp(applylut(BW3, LUT_ones));
```

Every neighbourhood index is 0. `LUT_ones(1) = 0`.

**Expected output:** all zeros (4 × 5 matrix of `0`).

---

### Test 4 — All-ones 3 × 3 matrix, `LUT_inv`

```scilab
BW4 = ones(3, 3) == 1;
disp(applylut(BW4, LUT_inv));
```

`LUT_inv` is `1` everywhere except index 511. The centre pixel reaches index 511 → `0`; all border pixels have indices < 511 → `1`.

**Expected output:**
```
1  1  1
1  0  1
1  1  1
```

---

### Test 5 — Isolated centre pixel, `LUT_center`

```scilab
BW5 = [%f, %f, %f; %f, %t, %f; %f, %f, %f];
disp(applylut(BW5, LUT_center));
```

The centre pixel contributes weight 16 (bit 4). Every neighbourhood that contains only the centre pixel active has index 16. `LUT_center(17) = 1`.

**Expected output:**
```
0  0  0
0  1  0
0  0  0
```

---

### Test 6 — 5 × 5 all-ones matrix, `LUT_ones` (border padding demonstration)

```scilab
BW6 = ones(5, 5) == 1;
disp(applylut(BW6, LUT_ones));
```

Demonstrates the zero-padding behaviour. Only the inner 3 × 3 core has all nine neighbours active; the border ring is partially zero-padded.

**Expected output (Scilab):**
```
0  0  0  0  0
0  1  1  1  0
0  1  1  1  0
0  1  1  1  0
0  0  0  0  0
```

*(Octave with replicate padding would produce all ones.)*

---

### Test 7 — Horizontal line detection, `LUT_line`

```scilab
BW7 = [%f, %f, %f, %f;
       %t, %t, %t, %t;
       %f, %f, %f, %f;
       %f, %f, %f, %f];
disp(applylut(BW7, LUT_line));
```

`LUT_line` fires at index 146. The second row provides the active neighbourhood pattern. Interior pixels of that row (with zero-padded borders accounted for) match index 146.

**Expected output:** a matrix where specific positions in the second-row region are `1`; all other entries are `0`. Exact values depend on which column positions accumulate index 146 given zero-padding.

---

## Mathematical Foundation

### Neighbourhood Index Formula

For a 3 × 3 neighbourhood centred at pixel (i, j), the index is:

```
         8
idx = Σ  BW(r, c) × 2^k(r,c)
        k=0
```

where k(r, c) is the **column-major position** of cell (r, c) in the 3 × 3 window (0 = top-left column, top row; 8 = bottom-right column, bottom row). This is exactly the value produced by a dot product of the boolean neighbourhood with the weight matrix:

```
┌─────┬─────┬─────┐
│  1  │  8  │ 64  │
│  2  │ 16  │ 128 │
│  4  │ 32  │ 256 │
└─────┴─────┴─────┘
```

### LUT Indexing

The result `idx` is a 0-based integer in [0, 511]. The LUT is accessed as:

```
A(i, j) = LUT( idx(i,j) + 1 )
```

The `+1` converts from 0-based (Octave convention) to 1-based (Scilab/Matlab convention).

### Why 512 entries?

A 3 × 3 neighbourhood has 9 binary pixels. Each of the 2⁹ = **512** possible neighbourhood patterns maps to a unique index, so the LUT must have exactly 512 entries to cover all patterns.

---

## IMPORTANT TO NOTICE 

| Limitation | Detail |
|------------|--------|

| Logical input required | `BW` must be a Scilab logical matrix; `bool2s` is applied internally. Passing a numeric 0/1 matrix without explicit conversion may produce unexpected results. |

---

## References

- GNU Octave — `applylut` documentation and reference implementation
- Scilab `conv2` documentation — convolution vs correlation distinction
- Shannon, C. E. (1948). *A Mathematical Theory of Communication.* Bell System Technical Journal.

---