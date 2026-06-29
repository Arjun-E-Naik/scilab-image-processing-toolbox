# `grayslice.sci`

---

## Overview

`grayslice` partitions the intensity range of a grayscale image into a set of **intervals** (or **levels**) and produces a labeled image in which each pixel is replaced by the index of the interval it falls into.

- **Scalar input `n`** → divides the range into `n` equally spaced levels.
- **Vector input `v`** → uses the provided thresholds to define irregular intervals.

The function is commonly used for **image segmentation**, **pseudo-colouring**, and **quantization**.

---

## Calling Sequence

```scilab
sliced = grayslice(I)        // default: 10 levels
sliced = grayslice(I, n)     // n = number of levels (scalar) or threshold vector
```

---

### Input Interpretation

| Input type | Behaviour |
|------------|-----------|
| **Scalar integer `n ≥ 1`** | Divides the range into `n` equal intervals using thresholds `(1:n-1)/n`. |
| **Scalar `0 < n < 1`**     | Treated as a **single threshold** at value `n` → two levels. |
| **Vector `v`**             | Uses the sorted unique values of `v` as thresholds → `length(v)+1` levels. |

---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `sliced` | `uint8` or `double` | Labeled image where each pixel is an interval index. The type depends on the number of levels. |

### Output Type Rule

- If **number of levels < 256** → `uint8` with labels **0 .. levels-1**.
- If **number of levels ≥ 256** → `double` with labels **1 .. levels**.

---


## Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric matrix | — | 2‑D grayscale image. Accepted Scilab types: `double`, `uint8`, `uint16`, `int16`, `int32`, `int64`, `uint32`, `uint64`, `logical`. |
| `n` | scalar or vector | `10` | Determines the number of levels or the exact thresholds. See [Input Interpretation]. |

---

## Dependencies

- `im2uint16` – converts `int16` images to `uint16` for consistent internal handling.
- `imcast` – used for type casting of thresholds 

---

## Complexity

| Stage | Complexity |
|-------|------------|
| Threshold sorting (vector case) | O(k log k), where k = length of `v` |
| Label assignment loop | O(R · C · k) |
| **Total** | O(R · C · k) |



---

## Test Cases with Expected Outputs

### Test 1 — Scalar `n = 10` (default)

```scilab
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, 10);
disp(ans);
```

**Expected output (uint8):**
```
0.   4.   5.   5.   9.
```

---

### Test 2 — Explicit threshold vector (equal to default)

```scilab
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]);
disp(ans);
```

**Expected output (uint8):**
```
0.   4.   5.   5.   9.
```

---

### Test 3 — Two levels (`n = 2`)

```scilab
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, 2);
disp(ans);
```

**Expected output (uint8):**
```
0.   0.   1.   1.   1.
```

---

### Test 4 — Vector thresholds with boundary values

```scilab
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, [0.5, 1]);
disp(ans);
```

**Expected output (uint8):**
```
0.   0.   1.   1.   2.
```

---

### Test 5 — Unsorted threshold vector

```scilab
im = [0, 0.5, 1];
ans = grayslice(im, [0, 1, 0.5]);
disp(ans);
```

**Expected output (uint8):**
```
1.   2.   3.
```

---

### Test 6 — Scalar between 0 and 1 (single threshold)

```scilab
im = [0, 0.5, 0.55, 0.7, 1];
ans = grayslice(im, 0.51);
disp(ans);
```

**Expected output (uint8):**
```
0.   0.   1.   1.   1.
```

---

### Test 7 — Repeated threshold values

```scilab
im = [0, 0.45, 0.5, 0.65, 0.7, 1];
ans = grayslice(im, [0.4, 0.5, 0.5, 0.7, 0.7, 1]);
disp(ans);
```

**Expected output (uint8):**
```
0.   1.   3.   3.   5.   6.
```

---

### Test 8 — Handling negative values and out‑of‑range thresholds (double)

```scilab
im = [-0.5, 0.1, 0.8, 1.2];
ans = grayslice(im, [-1, -0.4, 0.05, 0.6, 0.9, 1.1, 2]);
disp(ans);
```

**Expected output (uint8):**
```
1.   3.   4.   7.
```

*Explanation:* Thresholds outside `[min(I), max(I)]` are clipped to the image bounds.

---

### Test 9 — `n = 256` triggers `double` output type

```scilab
im = uint8(0:255);
ans = grayslice(im, 256);
disp(typeof(ans));
```

**Expected output (string):**
```
double
```

---

### Test 10 — `uint8` image with custom thresholds

```scilab
im = uint8([0, 100, 200, 255]);
ans = grayslice(im, [100, 199, 200, 210]);
disp(ans);
```

**Expected output (uint8):**
```
0.   1.   3.   4.
```

---

