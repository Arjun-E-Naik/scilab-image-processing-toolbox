# makelut.sci — Lookup Table Generator for Neighbourhood Functions

---

## Overview

**Lookup tables (LUTs)** are a core building block in morphological and neighbourhood-based image processing. `makelut` pre-computes the output of an arbitrary neighbourhood function for *every possible* binary input pattern, storing the results in a vector that can later be applied pixel-by-pixel at constant cost.

`makelut.sci` builds this table by:

1. Enumerating all 2^(n²) possible binary configurations of an n×n pixel neighbourhood.
2. Constructing a positional weight matrix that maps each cell to its bit significance in the integer encoding.
3. Decoding each integer index into an n×n logical matrix using bitwise AND against the weight matrix.
4. Evaluating the user-supplied function on each decoded neighbourhood matrix.
5. Collecting the results into a column vector **lut** of length 2^(n²).

The resulting LUT encodes an entire image-processing rule in a compact array that eliminates repeated function calls during image traversal — a standard technique in binary morphology pipelines.

---



---

## Calling Sequence

```
lut = makelut(fun, n)
lut = makelut(fun, n, arg1, arg2, arg3)
```

**Builds a lookup table by evaluating `fun` on every possible n×n binary neighbourhood.**

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fun` | function handle | A function with signature `y = fun(x)` or `y = fun(x, arg1, ...)`, where `x` is an n×n logical matrix and `y` is a scalar (typically 0 or 1). |
| `n` | positive integer scalar (≥ 2) | Neighbourhood side length. The LUT will have 2^(n²) entries. Common choices: **2** (4-pixel neighbourhood, 16-entry LUT) and **3** (9-pixel neighbourhood, 512-entry LUT). |
| `arg1, arg2, arg3` | any *(optional)* | Up to 3 extra arguments forwarded unchanged to `fun` on every call. |

#### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `lut` | column vector of doubles, length 2^(n²) | `lut(i+1)` holds the scalar returned by `fun` for the neighbourhood encoded by integer `i` (0-indexed). |

#### Errors

| Condition | Message raised |
|-----------|----------------|
| Fewer than 2 input arguments supplied | `makelut: Wrong number of input arguments.` |
| `n < 2` | `makelut: n should be a natural number >= 2` |

---
## Dependencies

### `feval()`

```
retval = feval(fun, idx, varargin)
```
| Parameter | Description |
|-----------|-------------|
| `fun` | Function handle to invoke. |
| `idx` | n×n logical matrix — the decoded neighbourhood. |
| `varargin` | 0 to 3 additional arguments passed through to `fun`. |
| **Returns `retval`** | Scalar output of `fun`. |

Passing more than 3 extra arguments raises: `feval: too many arguments`.

---
**Complexity:** O(c) = O(2^(n²)) iterations, each performing O(n²) bitwise operations plus one function call.
For n = 2: 16 iterations. For n = 3: 512 iterations. For n = 4: 65 536 iterations.

---

## Test Cases with Expected Outputs

All tests use **n = 3** (LUT length = 512) unless stated otherwise.

---

### Test 1 — `center_pixel`: Extract centre of neighbourhood

```scilab
function y = center_pixel(x)
    y = x(5);   // column-major index 5 = position (2,2) = centre cell
endfunction
lut = makelut(center_pixel, 3);
disp(lut(1:16));
```

**Logic:** Returns 1 exactly when the centre cell's bit (weight 16) is set in i.  
**First 16 entries (`lut(1:16)`):** All **0** — for i = 0…15 the centre bit (16) is never set.  
**LUT length:** 512  
**LUT sum:** 256 (exactly half of all 512 patterns have bit 4 set)  
**Unique values:** [0, 1]

---

### Test 2 — `always_zero`: Constant-zero function

```scilab
function y = always_zero(x)
    y = 0;
endfunction
lut = makelut(always_zero, 3);
```

**Logic:** Returns 0 for every neighbourhood pattern.  
**LUT length:** 512  
**LUT sum:** 0  
**Unique values:** [0]

---

### Test 3 — `always_one`: Constant-one function

```scilab
function y = always_one(x)
    y = 1;
endfunction
lut = makelut(always_one, 3);
```

**Logic:** Returns 1 for every neighbourhood pattern.  
**LUT length:** 512  
**LUT sum:** 512  
**Unique values:** [1]

---

### Test 4 — `majority`: Majority vote (≥ 5 of 9 pixels on)

```scilab
function y = majority(x)
    y = (sum(x(:)) >= 5);
endfunction
lut = makelut(majority, 3);
```

**Logic:** Returns 1 when at least 5 of the 9 cells are set.  
**Count derivation:**

```
C(9,5) + C(9,6) + C(9,7) + C(9,8) + C(9,9)
= 126  +   84   +   36   +    9   +    1    = 256
```

**LUT length:** 512  
**LUT sum:** 256  
**Unique values:** [0, 1]

---

### Test 5 — `single_pixel`: Exactly one pixel on

```scilab
function y = single_pixel(x)
    y = (sum(x(:)) == 1);
endfunction
lut = makelut(single_pixel, 3);
```

**Logic:** Returns 1 only for the 9 patterns where exactly one bit is set (one per cell position, i.e. i ∈ {1, 2, 4, 8, 16, 32, 64, 128, 256}).  
**LUT length:** 512  
**LUT sum:** 9  
**Unique values:** [0, 1]

---

### Test 6 — `all_on`: All pixels on (logical AND)

```scilab
function y = all_on(x)
    y = and(x(:));
endfunction
lut = makelut(all_on, 3);
```

**Logic:** Returns 1 only when all 9 bits are set, i.e. only for i = 511 (binary 111111111).  
**LUT length:** 512  
**LUT sum:** 1  
**Unique values:** [0, 1]

---

### Test 7 — `any_on`: Any pixel on (logical OR)

```scilab
function y = any_on(x)
    y = or(x(:));
endfunction
lut = makelut(any_on, 3);
```

**Logic:** Returns 0 only for i = 0 (all bits clear); returns 1 for every other pattern.  
**LUT length:** 512  
**LUT sum:** 511  
**Unique values:** [0, 1]

---

### Test 8 — `corner`: Top-left corner pixel

```scilab
function y = corner(x)
    y = x(1);   // column-major index 1 = position (1,1) = top-left corner
endfunction
lut = makelut(corner, 3);
```

**Logic:** Returns 1 when the top-left cell's bit (weight 256 = 2^8) is set, i.e. for all i ≥ 256.  
**LUT length:** 512  
**LUT sum:** 256  
**Unique values:** [0, 1]

---

### Test 9 — `parity`: Even number of pixels on

```scilab
function y = parity(x)
    y = (modulo(sum(x(:)), 2) == 0);
endfunction
lut = makelut(parity, 3);
```

**Logic:** Returns 1 when the popcount of i is even (0, 2, 4, 6, or 8 bits set).  
**Count derivation:**

```
C(9,0) + C(9,2) + C(9,4) + C(9,6) + C(9,8)
=   1   +   36   +  126   +   84   +    9   = 256
```

**LUT length:** 512  
**LUT sum:** 256  
**Unique values:** [0, 1]

---

### Test 10 — `rule2` with n = 2: At least 2 of 4 pixels on

```scilab
function y = rule2(x)
    y = (sum(x(:)) >= 2);
endfunction
lut = makelut(rule2, 2);   // n=2 → 2^4 = 16 entries
```

**Logic:** Uses a **2×2** neighbourhood (nq = 4 cells, c = 16 patterns). Returns 1 when 2 or more bits are set.  
**Count derivation:**

```
C(4,2) + C(4,3) + C(4,4)
=   6   +    4   +    1   = 11
```

**LUT length:** 16  
**LUT sum:** 11  
**Unique values:** [0, 1]

---

## Summary of Expected Test Outputs

| Test | Function | n | LUT length | LUT sum | Unique values |
|:----:|----------|:---:|:----------:|:-------:|:-------------:|
| 01 | `center_pixel` | 3 | 512 | 256 | [0, 1] |
| 02 | `always_zero` | 3 | 512 | 0 | [0] |
| 03 | `always_one` | 3 | 512 | 512 | [1] |
| 04 | `majority` (≥ 5) | 3 | 512 | 256 | [0, 1] |
| 05 | `single_pixel` | 3 | 512 | 9 | [0, 1] |
| 06 | `all_on` | 3 | 512 | 1 | [0, 1] |
| 07 | `any_on` | 3 | 512 | 511 | [0, 1] |
| 08 | `corner` | 3 | 512 | 256 | [0, 1] |
| 09 | `parity` (even) | 3 | 512 | 256 | [0, 1] |
| 10 | `rule2` (≥ 2) | 2 | 16 | 11 | [0, 1] |

---

## References

- GNU Octave — `makelut` function documentation
- MATLAB Image Processing Toolbox — `makelut` / `applylut`
- Gonzalez & Woods, *Digital Image Processing*, 3rd ed., §11 (Morphological Image Processing)
- Scilab `bitand`, `matrix`, `feval` documentation — https://www.scilab.org/scilab/help

---
