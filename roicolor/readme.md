# roicolor.sci

---


## Overview

**Region of Interest by Colour** (`roicolor`) produces a binary mask that identifies every element in an input array whose intensity value either lies within a closed range or matches one of a set of discrete target values. The resulting mask has the same shape as the input: `1` wherever the condition is met and `0` elsewhere.

`roicolor.sci` supports two calling forms:

1. **Range form** — given scalar bounds `low` and `high`, selects every element satisfying `low ≤ A(i,j) ≤ high`.
2. **Vector form** — given a value vector `v`, selects every element equal to any member of `v`.



---


### `roicolor()`

```
BW = roicolor(A, low, high)
BW = roicolor(A, v)
```

**Creates a binary mask selecting elements within an intensity range or matching a discrete value set.**

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `A` | numeric array (any shape, any numeric type) | Input image or data array. May be 2-D (grayscale), 1-D (signal), or any N-D array. Elements are compared in place; the array is not flattened before processing. |
| `low` | scalar numeric | Lower bound of the selection range (inclusive). Three-argument form only. Must be a scalar; a non-scalar argument raises an error. |
| `high` | scalar numeric | Upper bound of the selection range (inclusive). Three-argument form only. Must be a scalar; a non-scalar argument raises an error. |
| `v` | numeric vector (row or column) | Set of discrete target values. Two-argument form only. Must be a vector; a matrix argument raises an error. |

#### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `BW` | double array, same size as `A` | Binary mask. `1.0` where the condition is satisfied, `0.0` elsewhere. Always `double`, regardless of the numeric type of `A`. |

---



## Test Cases with Expected Outputs

### Test 1 — 1-D Array, Range Form `low=2, high=4`

```scilab
A1 = 1:6;
BW = roicolor(A1, 2, 4);
```

**Condition:** `2 ≤ x ≤ 4`

| Position | 1 | 2 | 3 | 4 | 5 | 6 |
|----------|---|---|---|---|---|---|
| Value    | 1 | 2 | 3 | 4 | 5 | 6 |
| `≥ 2`    | F | T | T | T | T | T |
| `≤ 4`    | T | T | T | T | F | F |
| **BW**   | 0 | 1 | 1 | 1 | 0 | 0 |

**Expected output:** `BW = [0, 1, 1, 1, 0, 0]`

---

### Test 2 — 2×3 Matrix, Range Form `low=3, high=5`

```scilab
A2 = [1 2 3; 4 5 6];
BW = roicolor(A2, 3, 5);
```

**Condition:** `3 ≤ x ≤ 5`, evaluated element-wise:

```
A2 >= 3 :  [F F T; T T T]
A2 <= 5 :  [T T T; T T F]
AND     :  [F F T; T T F]
```

**Expected output:**
```
BW = [0  0  1]
     [1  1  0]
```

---

### Test 3 — Degenerate Range `low=high=3`

```scilab
A3 = [1 2; 3 4];
BW = roicolor(A3, 3, 3);
```

**Condition:** `3 ≤ x ≤ 3` ≡ `x == 3`. Only the element at position (2,1) satisfies the condition:

```
A3 >= 3 :  [F F; T T]
A3 <= 3 :  [T T; T F]
AND     :  [F F; T F]
```

**Expected output:**
```
BW = [0  0]
     [1  0]
```

---

### Test 4 — 2×2 Matrix, Vector Form `v=[1, 4]`

```scilab
A4 = [1 2; 3 4];
BW = roicolor(A4, [1, 4]);
```

**Condition:** `x ∈ {1, 4}`. Two equality passes combined by OR:

```
A4 == 1 :  [T F; F F]
A4 == 4 :  [F F; F T]
OR      :  [T F; F T]
```

**Expected output:**
```
BW = [1  0]
     [0  1]
```

---

### Test 5 — 1-D Array, Vector Form `v=[2, 5, 8]`

```scilab
A5 = 1:10;
BW = roicolor(A5, [2, 5, 8]);
```

**Condition:** `x ∈ {2, 5, 8}`. Three OR passes, one per target value:

| Position | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|----------|---|---|---|---|---|---|---|---|---|----|
| Value    | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
| `== 2`   | F | T | F | F | F | F | F | F | F | F  |
| `== 5`   | F | F | F | F | T | F | F | F | F | F  |
| `== 8`   | F | F | F | F | F | F | F | T | F | F  |
| **BW**   | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 1 | 0 | 0  |

**Expected output:** `BW = [0, 1, 0, 0, 1, 0, 0, 1, 0, 0]`

---

### Test 6 — `uint8` Matrix, Range Form `low=100, high=200`

```scilab
A6 = uint8([10 50 100; 150 200 250]);
BW = roicolor(A6, 100, 200);
```

**Condition:** `100 ≤ x ≤ 200`. Scilab's relational operators work uniformly across integer types; `bool2s` always returns `double`:

```
A6 >= 100 :  [F F T; T T T]
A6 <= 200 :  [T T T; T T F]
AND       :  [F F T; T T F]
```

**Expected output:**
```
BW = [0  0  1]
     [1  1  0]
```

---

### Test 7 — All-Zero Output: Range Out of Bounds `low=10, high=20`

```scilab
A7 = [1 2; 3 4];
BW = roicolor(A7, 10, 20);
```

**Condition:** `10 ≤ x ≤ 20`. No element of A7 falls in [10, 20]; the first inequality is universally false:

```
A7 >= 10 :  [F F; F F]
(AND is trivially zero)  →  [0  0; 0  0]
```

**Expected output:** All-zero 2×2 matrix.

---

### Test 8 — All-Zero Output: Vector Out of Bounds `v=[6, 7]`

```scilab
A8 = [1 2; 3 4];
BW = roicolor(A8, [6, 7]);
```

**Condition:** `x ∈ {6, 7}`. Neither value is present in A8; both equality passes yield all-false:

```
A8 == 6 :  [F F; F F]
A8 == 7 :  [F F; F F]
OR      :  [F F; F F]  →  [0  0; 0  0]
```

**Expected output:** All-zero 2×2 matrix.

---

### Test 9 — Floating-Point Array, Range Form `low=0.4, high=0.6`

```scilab
A9 = [0.1 0.5; 0.9 0.4];
BW = roicolor(A9, 0.4, 0.6);
```

**Condition:** `0.4 ≤ x ≤ 0.6`. Boundary value 0.4 is included (closed interval):

```
A9 >= 0.4 :  [F T; T T]    (0.1 < 0.4; 0.5 ≥ 0.4; 0.9 ≥ 0.4; 0.4 ≥ 0.4)
A9 <= 0.6 :  [T T; F T]    (0.1 ≤ 0.6; 0.5 ≤ 0.6; 0.9 > 0.6; 0.4 ≤ 0.6)
AND       :  [F T; F T]
```

**Expected output:**
```
BW = [0  1]
     [0  1]
```

---

### Test 10 — Error: Non-Scalar Bounds

```scilab
try
    roicolor([1 2; 3 4], [1 2], [3 4]);
catch
    disp(lasterror());
end
```

**Condition:** Three-argument form invoked with `p1 = [1, 2]` and `p2 = [3, 4]`. Both fail `isscalar()`. The guard raises an error immediately, before any comparison is performed.

**Expected output:** Error: `"roicolor: low and high must be scalars."`

---


## References

[1] GNU Octave Image Package — `roicolor` function source

[2] MATLAB Image Processing Toolbox — `roicolor` documentation

---
---