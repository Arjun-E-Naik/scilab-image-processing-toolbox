# Optimized Binary Morphological Thinning for Scilab  
### LUT-Based Zhang–Suen Skeletonization Implementation

## Overview

This is optimized binary image thinning algorithm  using a Lookup Table (LUT) based version of the Zhang–Suen thinning algorithm.

The implementation supports:

- Binary image thinning
- Skeleton extraction
- Iterative morphology
- Infinite or fixed iteration execution
- LUT-accelerated deletion rules


---

# Background

Morphological thinning is a process used to reduce binary objects into thin skeletal representations while preserving connectivity and topology.

Applications include:
- Character recognition
- Shape analysis
- Road/network extraction

Example:

Input:

```text
111111
111111
111111
111111
```

Output:

```text
000100
000100
000100
000100
```

The structure is reduced while preserving its shape.

---

# Zhang–Suen Thinning Algorithm

The implementation uses the classical Zhang–Suen iterative thinning algorithm.

Reference:

Zhang, T.Y., Suen, C.Y.

"A Fast Parallel Algorithm for Thinning Digital Patterns"
Communications of ACM, 1984

---

# Neighborhood Representation

The neighborhood around a pixel P1:

```text
P9   P2   P3
P8   P1   P4
P7   P6   P5
```

P1:

Current center pixel

Neighbors:

P2–P9

Clockwise ordering is important.

---

# Mathematical Definitions

Two quantities are computed:

## 1. Neighbor Count

B(P)

Counts foreground neighbors:

```math
B(P)=P2+P3+P4+P5+P6+P7+P8+P9
```

Constraint:

```math
2 \le B(P)\le6
```

T0o avoid deleting isolated pixels and preserve structures.

---

## 2. Transition Count

A(P)

Counts number of transitions from:

```text
0 --> 1
```

while traversing:

```text
P2,P3,P4,P5,P6,P7,P8,P9,P2
```

Mathematically:

```math
A(P)=\sum(P_i=0 \cap P_{i+1}=1)
```

Constraint:

```math
A(P)=1
```

Purpose:

Preserves connectivity.

---

# Step 1 Deletion Rules

Delete pixel if:

```math
2\le B(P)\le6
```

and

```math
A(P)=1
```

and

```math
P2\times P4\times P6=0
```

and

```math
P4\times P6\times P8=0
```

---

# Step 2 Deletion Rules

Delete pixel if:

```math
2\le B(P)\le6
```

and

```math
A(P)=1
```

and

```math
P2\times P6\times P8=0
```

and

```math
P2\times P4\times P8=0
```

---

# Algorithm Flow

```text
Input Binary Image
        |

Convert to Binary
        |

Build Lookup Tables
        |

Iteration Start
        |

Pass 1:
    Compute neighborhood code
    LUT lookup
    Mark deletions
        |

Delete pixels
        |

Pass 2:
    Compute neighborhood code
    LUT lookup
    Mark deletions
        |

Delete pixels
        |

Repeat until stable
        |

Output skeleton
```

---

# Lookup Table Optimization

Traditional implementations repeatedly compute:

- neighbor count
- transition count
- logical conditions

for every pixel.

This becomes expensive:

```text
for each iteration
    for each row
        for each column
```

Instead:

All possible neighborhood configurations are precomputed.

Since:

```math
2^8=256
```

there are only:

```text
256
```

possible neighborhoods.

Thus:

```text
Neighborhood
      |
Binary Code
      |
LUT
      |
Delete or Keep
```

This replaces repeated logical computation.

---

# Binary Neighborhood Encoding

Neighborhood bits:

```text
P2 P3 P4 P5 P6 P7 P8 P9
```

Code:

```math
Code=
P2·2^0+
P3·2^1+
P4·2^2+
P5·2^3+
P6·2^4+
P7·2^5+
P8·2^6+
P9·2^7
```

Example:

```text
1 0 1
0 X 1
0 0 1
```

Neighbors:

```text
P2=1
P3=0
P4=1
P5=1
P6=0
P7=0
P8=0
P9=1
```

Code:

```math
1+0+4+8+0+0+0+128
```

Result:

```text
141
```

Lookup:

```scilab
lut(142)
```

(Scilab indexing starts at 1)

---


# Main Function

Syntax:

```scilab
out=bwmorph_thin_fast(bw,n)
```

Parameters:

 bw --> binary image 
 n --> number of iterations 

If:

```scilab
n=%inf
```

algorithm runs until convergence.

---

# Example Usage

Load image:

```scilab
img=imread("shape.png");
```

Convert:

```scilab
bw=im2bw(img);
```

Run:

```scilab
out=bwmorph_thin_fast(bw);
```

Display:

```scilab
imshow(out);
```

---

# Fixed Iteration Example

```scilab
out=bwmorph_thin_fast(bw,5);
```

Only:

```text
5
```

iterations executed.

---

# Complexity Analysis

Let:

```text
Image size = M×N
Iterations = k
```

## Traditional Implementation

Time:

```math
O(kMN)
```

Space:

```math
O(MN)
```

Large constants due to repeated neighborhood computations.

---

## LUT-Based Implementation

Time:

```math
O(kMN)
```

Space:

```math
O(MN)+256
```

Additional memory:

```text
256 LUT entries
```

Although asymptotic complexity remains identical, practical execution time is significantly improved.

---


### 1. LUT-Based Rule Evaluation

Instead of recomputing:

- B(P)
- A(P)
- deletion conditions

during every iteration,

all:

```text
256 neighborhood patterns
```

are precomputed.

---

### 2. Binary Neighborhood Encoding

Neighborhoods are transformed into integer codes:

```text
0–255
```

allowing direct indexing.

---

### 3. Reduced Conditional Computation

Expensive conditional operations inside nested loops are minimized.

---

### 4.  Design

Implementation divided into:

- LUT generation
- transition computation
- thinning engine

This improves maintainability.


---

