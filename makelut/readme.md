# makelut.sci — Lookup Table Generator for Neighbourhood Functions in Scilab

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

## Quick Start

```scilab
// Load the function
exec('makelut.sci', -1)

// Build a LUT that returns the centre pixel of every 3×3 neighbourhood
function y = center_pixel(x)
    y = x(5);
endfunction

lut = makelut(center_pixel, 3);
disp(length(lut));   // 512
disp(sum(lut));      // 256

// Run the full test suite
exec('test_makelut.sci', -1)
```

---

## API Reference

### `makelut()`

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

### `feval()` — internal helper

```
retval = feval(fun, idx, varargin)
```

A lightweight dispatcher that invokes `fun(idx)`, `fun(idx, arg1)`, `fun(idx, arg1, arg2)`, or `fun(idx, arg1, arg2, arg3)` depending on the number of extra arguments. It mirrors the role of MATLAB/Octave's built-in `feval` while remaining compatible with Scilab's function-call model.

| Parameter | Description |
|-----------|-------------|
| `fun` | Function handle to invoke. |
| `idx` | n×n logical matrix — the decoded neighbourhood. |
| `varargin` | 0 to 3 additional arguments passed through to `fun`. |
| **Returns `retval`** | Scalar output of `fun`. |

Passing more than 3 extra arguments raises: `feval: too many arguments`.

---

## Variable Reference

| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `fun` | input | function handle | User-supplied neighbourhood function. |
| `n` | input | integer scalar | Neighbourhood side length (≥ 2). |
| `varargin` | input | cell array | Optional extra arguments forwarded to `fun`. |
| `nq` | local | integer | Total neighbourhood cells: n². |
| `c` | local | integer | Total LUT entries: 2^(n²). |
| `lut` | output | double column vector, length `c` | The computed lookup table. |
| `w` | local | n×n int32 matrix | Weight matrix. `w` is filled column-major with the values 2^(nq−1), 2^(nq−2), …, 2^0, so each cell holds a unique power-of-two bit mask. |
| `i` | loop variable | integer | Current neighbourhood index in the range 0 to c−1. |
| `idx` | local | n×n logical matrix | Decoded neighbourhood for index `i`: `idx(r,c) = (bitand(w(r,c), i) > 0)`. |
| `lhs`, `rhs` | local | integers | Left-hand / right-hand argument counts, obtained via `argn(0)`. |
| `nargs` | local (feval) | integer | Number of extra arguments supplied to `fun`. |
| `retval` | local (feval) | scalar | Return value of `fun` for the current neighbourhood. |

---

## Algorithm Explanation

```
Inputs: fun, n [, optional args]
            │
            ▼
┌────────────────────────────────────────────────────────┐
│  1. Validate inputs                                     │
│     – rhs >= 2  (both fun and n must be supplied)       │
│     – n >= 2    (neighbourhood must have >= 4 cells)    │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────┐
│  2. Compute dimensions                                  │
│     nq = n²           (cells per neighbourhood)         │
│     c  = 2^nq         (total distinct binary patterns)  │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────┐
│  3. Build weight matrix  w  (n×n, int32)                │
│     Filled column-major with 2^(nq-1), …, 2^1, 2^0.   │
│     Each cell gets a unique power-of-two bit mask so    │
│     that integer i encodes exactly one n×n pattern.     │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼
┌────────────────────────────────────────────────────────┐
│  4. For i = 0, 1, …, c−1:                              │
│                                                         │
│     a. Decode                                           │
│        idx = (bitand(w, i) > 0)                         │
│        → idx(r,c) = %T  iff bit w(r,c) is set in i     │
│                                                         │
│     b. Evaluate                                         │
│        lut(i+1) = feval(fun, idx, optional_args)        │
│        → calls user function with n×n logical matrix    │
└───────────────────────┬────────────────────────────────┘
                        │
                        ▼
                    Return lut
```

**Complexity:** O(c) = O(2^(n²)) iterations, each performing O(n²) bitwise operations plus one function call.
For n = 2: 16 iterations. For n = 3: 512 iterations. For n = 4: 65 536 iterations.

---

## Mathematical Foundation

### Neighbourhood Encoding

Every binary n×n neighbourhood is placed in bijection with an integer i ∈ {0, 1, …, 2^(n²)−1} via the weight matrix **W**, whose cells are filled column-major with descending powers of two:

```
         n   n
i   =   Σ   Σ  x(r,c) · W(r,c)
        r=1 c=1
```

The decoding step reverses this mapping using bitwise AND:

```
x(r,c) = 1    iff    bitand( W(r,c), i ) ≠ 0
```

### Weight Matrix Layout (n = 3)

The 3×3 weight matrix, filled column-major with 2^8, 2^7, …, 2^0:

```
        Col 1   Col 2   Col 3
Row 1 │  256      32      4  │
Row 2 │  128      16      2  │
Row 3 │   64       8      1  │
```

Column-major linear positions and their weights:

| Linear index | (row, col) | Weight | Bit position |
|:---:|:---:|:---:|:---:|
| 1 | (1,1) | 256 | bit 8 — top-left corner |
| 2 | (2,1) | 128 | bit 7 |
| 3 | (3,1) | 64  | bit 6 |
| 4 | (1,2) | 32  | bit 5 |
| **5** | **(2,2)** | **16** | **bit 4 — centre** |
| 6 | (3,2) | 8   | bit 3 |
| 7 | (1,3) | 4   | bit 2 |
| 8 | (2,3) | 2   | bit 1 |
| 9 | (3,3) | 1   | bit 0 — bottom-right |

### LUT Indexing Convention

Scilab arrays are 1-indexed, so the neighbourhood integer i maps to:

```
lut( i + 1 )  =  fun( decode(i) )
```

### LUT Size vs. Neighbourhood Size

| n | n² (cells) | LUT length |
|:---:|:---:|:---:|
| 2 | 4  | 16 |
| 3 | 9  | 512 |
| 4 | 16 | 65 536 |

### Counting Non-Zero LUT Entries

For functions that count set bits, the number of positive LUT entries follows from binomial coefficients. For example, with n = 3 (9-bit neighbourhood) and threshold k:

```
  number of patterns with exactly k bits set  =  C(9, k)
```

This makes it straightforward to predict the LUT sum analytically (see test cases below).

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