# applylut.sci — Neighbourhood Look-Up Table Application

---

## Overview

`applylut` applies a **neighbourhood look-up table (LUT)** to a binary image. For every pixel in the image it examines the pixel's neighbourhood, converts that neighbourhood into an integer index, and replaces the pixel's output value with the entry at that index in the LUT.

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
| `A` | double matrix, same size as `BW` | Output image. Each pixel holds the LUT value selected by its neighbourhood index. Border pixels are zero-padded . |

## Dependencies

### `filter2()` 

```
y = filter2(b, x)
y = filter2(b, x, shape)
```


| Parameter | Type | Description |
|-----------|------|-------------|
| `b` | numeric matrix | The filter kernel (applied via correlation). |
| `x` | numeric matrix | The signal/image to filter. |
| `shape` | string *(optional)* | Output size: `"same"` (default), `"full"`, or `"valid"`. Passed directly to `conv2`. |

**Returns `y`:** filtered matrix of the size determined by `shape`.

---

## Importance to Notice
`applylut()` function need input image and `lookup table` .
For the test cases , the octave version use the below syntax to construct the lookup table, but this syntax is invalid in scilab.
```octave
lut = makelut (@(x) sum (x (:)) >= 3, 3); %! for construct the LUT ,here `@(x) sum(x(:))>3` 
S = applylut (eye (5), lut);
disp (S);
```
for  constructing lookup table octave uses `makelut()` function, in scilab to construct lookup table. You have to explicitly create `condition function` and then pass to `makelut()`.
For example,
```scilab
function res = fun(idx)
    res = double(sum(idx) >= 3);
endfunction

LUT = makelut(fun, 3);
BW2 = eye(5, 5);
disp(applylut(BW2, LUT));

```
## Test Cases with Expected Outputs
```
// For execution of script and test cases.
exec("applylut.sci",-1); 
```
### Test 1 — Alternating 3 × 3 matrix, 

```scilab
function res = func(idx)
    res = double(and(idx)); // Returns 1 only if ALL elements in the 3x3 grid are 1
endfunction

LUT = makelut(func, 3);

BW1 = [%f, %t, %f; %t, %f, %t; %f, %t, %f];
disp(applylut(BW1, LUT));
```

No pixel has all nine neighbours set to `1`, so no index reaches 511.

**Expected output:** 
```
0  0  0
0  0  0
0  0  0
```

---

### Test 2 — All-ones 3 × 3 matrix

```scilab
function res = func(idx)
    res = double(and(idx)); 
endfunction

LUT = makelut(func, 3);

BW2 = ones(3, 3) == 1;
disp(applylut(BW2, LUT));
```

Only the centre pixel has all nine neighbours equal to `1` (the border pixels are zero-padded). Index 511 is reached only at position (2,2).

**Expected output:**
```
0  0  0
0  1  0
0  0  0
```

---

### Test 3 — All-zeros 4 × 5 matrix.

```scilab
function res = func(idx)
    res = double(and(idx)); 
endfunction

LUT = makelut(func, 3);
BW3 = zeros(4, 5) == 1;
disp(applylut(BW3, LUT));
```

Every neighbourhood index is 0. `LUT(1) = 0`.

**Expected output:** 
```
   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.
```

---

### Test 4 — All-ones 3 × 3 matrix.

```scilab
function res = func(idx)
    res = double(~and(idx));
endfunction
LUT = makelut(func, 3);
BW4 = ones(3, 3) == 1;
disp(applylut(BW4, LUT));
```

`LUT` is `1` everywhere except index 511. The centre pixel reaches index 511 → `0`; all border pixels have indices < 511 → `1`.

**Expected output:**
```
1  1  1
1  0  1
1  1  1
```

---

### Test 5 — Isolated centre pixel,

```scilab
LUT = zeros(512, 1);
LUT(17) = 1;
BW5 = [%f, %f, %f; %f, %t, %f; %f, %f, %f];
disp(applylut(BW5, LUT));
```

The centre pixel contributes weight 16 (bit 4). Every neighbourhood that contains only the centre pixel active has index 16. `LUT(17) = 1`.

**Expected output:**
```
0  0  0
0  1  0
0  0  0
```

---

### Test 6 — 5 × 5 all-ones matrix, (border padding demonstration)

```scilab
LUT = zeros(512, 1);
LUT(512) = 1;
BW6 = ones(5, 5) == 1;
disp(applylut(BW6, LUT));
```

Demonstrates the zero-padding behaviour. Only the inner 3 × 3 core has all nine neighbours active; the border ring is partially zero-padded.

**Expected output:**
```
0  0  0  0  0
0  1  1  1  0
0  1  1  1  0
0  1  1  1  0
0  0  0  0  0
```



---

### Test 7 — Horizontal line detection, 

```scilab
LUT = zeros(512, 1);
LUT(147) = 1;
BW7 = [%f, %f, %f, %f;
       %t, %t, %t, %t;
       %f, %f, %f, %f;
       %f, %f, %f, %f];
disp(applylut(BW7, LUT));
```

`LUT` fires at index 146. The second row provides the active neighbourhood pattern. Interior pixels of that row (with zero-padded borders accounted for) match index 146.

**Expected output:** 
```
0.   0.   0.   0.
0.   1.   1.   0.
0.   0.   0.   0.
0.   0.   0.   0.
```
---


### Test 8 — Error detection, 
```scilab
img = [1,0,1; 0,1,0; 1,0,1];
try
    applylut(img);
catch
    [msg, err] = lasterror();
    mprintf("Caught: %s\n", msg);
end
```
**Expected output:** 
```
Synatx Error
```

### Test 9 — Error detection,
```scilab
img = [1,0,1; 0,1,0; 1,0,1];
lut = zeros(100, 1); 
try
    applylut(img, lut);
catch
    [msg, err] = lasterror();
    mprintf("Caught: %s\n", msg);
end

```
**Expected output:** 
```
Synatx Error
```
---
