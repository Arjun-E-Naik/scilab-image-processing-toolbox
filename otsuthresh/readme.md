
# `otsuthresh.sci`

---

## Overview

`otsuthresh` computes the **global threshold** of a histogram using **Otsu's thresholding method**. The algorithm determines the threshold that maximizes the **between-class variance**, thereby separating the histogram into two classes with maximum discrimination.

 `graythresh`, which accepts either an image or a histogram, **`otsuthresh` accepts only a histogram vector** and returns the normalized threshold in the range **[0, 1]**.


---

## Calling Sequence

```scilab
T = otsuthresh(hist)
```

---

## Input Parameters

| Variable | Type | Description |
|----------|------|-------------|
| `hist` | Numeric vector | Histogram containing non-negative integer frequencies. The histogram must be real-valued and one-dimensional. |

---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `T` | double | Normalized Otsu threshold between **0** and **1**. |

---


## Dependencies

- `graythresh` – performs threshold computation.
- Internal Otsu implementation inside `graythresh`.

---

## Complexity

Let **N** be the number of histogram bins.

| Stage | Complexity |
|-------|------------|
| Cumulative sums | O(N) |
| Mean computation | O(N) |
| Between-class variance computation | O(N) |
| Maximum search | O(N) |
| **Total** | **O(N)** |

---

# Test Cases with Expected Outputs

---

## Test 1 — Simple bimodal histogram

```scilab
h = [10, 2, 2, 10];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.3333333
```

---

## Test 2 — Gradual symmetric histogram

```scilab
h = [8,6,4,6,8];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.375
```

---

## Test 3 — Histogram with dominant first peak

```scilab
h = [20,5,3,2,1,1];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.2
```

(The exact value depends on the Otsu criterion.)

---

## Test 4 — Minimal 3-bin histogram

```scilab
h = [5,1,5];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.25
```

---

## Test 5 — Uniform histogram

```scilab
h = [3,3,3,3,3,3,3,3];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.4285714
```

---

## Test 6 — Two well-separated groups

```scilab
h = [15,12,1,0,0,8,10];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0.5
```

---

## Test 7 — Single-bin histogram

```scilab
h = [5];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0
```

---

## Test 8 — Two-bin histogram

```scilab
h = [3,7];
t = otsuthresh(h);
disp(t);
```

**Expected output**

```
0
```

Since only one possible threshold exists, the normalized threshold is zero.

---

# Error Handling Tests

---

## Error Test 1 — Empty vector

```scilab
otsuthresh([])
```

**Expected**

```
Error
```

because the histogram must contain at least one element.

---

## Error Test 2 — Negative values

```scilab
otsuthresh([2,-1,5,3])
```

**Expected**

```
otsuthresh: HIST must be a vector of non-negative integers
```

---

## Error Test 3 — Non-integer values

```scilab
otsuthresh([2.5,3.1,4.0,1.2])
```

**Expected**

```
otsuthresh: HIST must be a vector of non-negative integers
```

---

## Error Test 4 — Matrix input

```scilab
otsuthresh([1 2;3 4])
```

**Expected**

```
otsuthresh: HIST must be a vector of non-negative integers
```

---





