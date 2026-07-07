# `bwmorph.sci` — Binary Image Morphological Operations



---



## Overview

| | |
|---|---|
| **Function** | `bwmorph(bw, operation [, n])` |
| **Purpose** | Apply a named morphological transform to a binary image, `n` times (or until convergence with `n = %inf`) |
| **Input class** | numeric or boolean matrix, any dimensionality (2‑D required for LUT-based ops, N‑D allowed for structuring-element ops) |
| **Output class** | boolean, same shape as input |
| **Dependencies** | `strel_hypercube`, `imfilter_nd`, `conndef`, `dilate`, `erode`, `open`, `close`, `tophat`, `bothat`, `filter2`, `applylut` (all must be loaded/defined before calling `bwmorph`) |
| **Source** | Octave Forge `image` package, `bwmorph.m` (Copyright Josep Mones i Teixidor, Carnë Draug) |

---



## Calling Sequence

### `bwmorph`

```
bw2 = bwmorph(bw, operation)
bw2 = bwmorph(bw, operation, n)
```

**Inputs**

| Parameter | Type | Description |
|---|---|---|
| `bw` | numeric \| boolean matrix | Input binary image. Non-boolean input is converted via `bw <> 0`. |
| `operation` | string | One of the 21 supported operation names (case-insensitive). See table below. |
| `n` | scalar (optional) | Number of iterations. Default `1`. Negative values silently reset to `1` (undocumented Octave-compatibility quirk, preserved intentionally). Use `%inf` to iterate until the image stops changing. |

**Output**

| Parameter | Type | Description |
|---|---|---|
| `bw2` | boolean matrix | Transformed image, same shape as `bw`. |

**Errors**

| Condition | Message |
|---|---|
| `argn(2) < 2` or `> 3` | `"bwmorph: need 2 or 3 arguments: bwmorph(bw, operation [, n])"` |
| `bw` not numeric/boolean | `"bwmorph: BW must be a numeric or boolean matrix"` |
| `operation` not a string | `"bwmorph: OPERATION must be a string"` |
| `n` not scalar numeric | `"bwmorph: N must be a scalar"` |
| unknown `operation` | `"bwmorph: unknown OPERATION '<name>'"` |

---



## Helper / Dependency Functions

| Function | Signature | What it does |
|---|---|---|
| `strel_hypercube` | `se = strel_hypercube(n, edge_size)` | Builds an N-dimensional all-true structuring element of shape `repmat(edge_size, 1, n)` |
| `imfilter_nd` | `R = imfilter_nd(A, K, pad_val)` | Shift-and-add convolution supporting 2‑D/3‑D, with explicit boundary padding value (replaces Octave's `convn`) |
| `conndef` | `conn = conndef(num_dims, "minimal"/"maximal")` or `conndef(conn_matrix)` or `conndef(scalar)` | Builds standard connectivity kernels (equivalent to Octave/MATLAB's `conndef`) |
| `dilate` | `R = dilate(A, se)` | `imfilter_nd(A, se, 0) > 0` |
| `erode` | `R = erode(A, se)` | `imfilter_nd(A, se, 1) >= sum(se(:))` (pads with 1s so border isn't spuriously eroded) |
| `open` | `R = open(A, se)` | `dilate(erode(A, se), se)` |
| `close` | `R = close(A, se)` | `erode(dilate(A, se), se)` |
| `tophat` | `R = tophat(A, se)` | `A & ~open(A, se)` |
| `bothat` | `R = bothat(A, se)` | `close(A, se) & ~A` |
| `filter2` | `y = filter2(b, x, shape)` | 2‑D correlation via `conv2` with kernel flip, matches MATLAB/Octave `filter2` semantics |
| `applylut` | `A = applylut(BW, LUT)` | Applies a `2^(n²)`-entry lookup table over every pixel's `n×n` binary neighbourhood (used with `n=3`, i.e. 512-entry LUTs, throughout `bwmorph`) |

---




---

## Worked Test Cases

### Test 1 — `clean`

```scilab
in  = ([0 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "clean");
disp(double(out));
```
Expected:
```
0 0 0
0 0 1
0 0 1
```
Pixel `(2,1)` has no true 8-neighbours → removed. Pixel `(2,3)`/`(3,3)` touch each other → kept.

### Test 2 — `bridge`

```scilab
in  = ([1 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "bridge");
disp(double(out));
```
Expected:
```
1 1 0
1 1 1
0 1 1
```

### Test 3 — `dilate`

```scilab
in  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
out = bwmorph(in, "dilate");
disp(double(out));
```
Expected: `ones(3,3)` — the lone center pixel dilates to fill its full 3×3 neighbourhood.

### Test 4 — `erode`

```scilab
in  = ones(3,3) ~= 0;
out = bwmorph(in, "erode");
disp(double(out));
```
Expected:
```
0 0 0
0 1 0
0 0 0
```
Only the center pixel has all 8 neighbours true.

### Test 5 — `remove`

```scilab
in  = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
out = bwmorph(in, "remove");
disp(double(out));
```
Expected:
```
0 1 0 0 0
1 0 0 1 0
1 0 1 0 0
1 1 0 1 1
1 1 1 1 1
```
Pixel `(4,3)` has all four-connected neighbours true → interior pixel removed.

### Test 6 — `endpoints`

```scilab
in  = ([0 0 0 0 0; 0 0 1 0 0; 0 1 1 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
out = bwmorph(in, "endpoints");

disp(double(out));
```
Expected:
```
0 0 0 0 0
0 0 1 0 0
0 1 0 1 0
0 0 1 0 0
0 0 0 0 0
```


### Test 7 — `skel-lantuejoul` (Gonzalez & Woods fig. 8.39)

```scilab
slBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
         0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; ...
         0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 0 0 0 0] ~= 0);

out_n1  = bwmorph(slBW, "skel-lantuejoul", 1);
out_n3  = bwmorph(slBW, "skel-lantuejoul", 3);
out_inf = bwmorph(slBW, "skel-lantuejoul", %inf);

disp(double(out_n1));

disp(double(out_n3));

disp(double(out_inf));
```
Expected:
```
 "test for out_n1 function"
   0.   0.   0.   0.   0.   0.   0.
   0.   1.   0.   0.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.


  "test for out_n3 function"
   0.   0.   0.   0.   0.   0.   0.
   0.   1.   0.   0.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.


  "test for out_inf function"
   0.   0.   0.   0.   0.   0.   0.
   0.   1.   0.   0.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   1.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   1.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
```

### Test 8 — `thin`

```scilab
in  = ones(5, 7) ~= 0;
out = bwmorph(in, "thin", %inf);
disp(double(out));
```
Expected:
```
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   1.   1.   1.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
   0.   0.   0.   0.   0.   0.   0.
```

### Test 9 — `majority` (regression test for the `loop_once` fix)

```scilab
in  = ([1 1 0; 1 0 0; 0 0 1] ~= 0);
out1 = bwmorph(in, "majority", 1);
out3 = bwmorph(in, "majority", 3);
disp(double(out1));

disp(double(out3));
```
```
Out1 (1 iteration):
   0   0   0
   0   0   0
   0   0   0
Out3 (3 iterations):
   0   0   0
   0   0   0
   0   0   0
```

### Test 10 — `thicken`

```scilab
bw = bool2s(zeros(8, 7));
bw(8, 1) = %t;
out = bwmorph(bw, "thicken", 6);
disp(double(out));
```
Expected:
```
0 0 0 0 0 0 0
1 0 0 0 0 0 0
1 1 0 0 0 0 0
1 1 1 0 0 0 0
1 1 1 1 0 0 0
1 1 1 1 1 0 0
1 1 1 1 1 1 0
1 1 1 1 1 1 1
```

---

