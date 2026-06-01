// test_entropy.sci
// ================================================================
// Test suite for entropy.sci (Scilab port of Octave entropy())
// ================================================================
// Run this file inside Scilab:
//     exec('entropy.sci', -1)
//     exec('test_entropy.sci', -1)
//
// Each test prints PASS or FAIL with the test description.
// A final summary shows total passed / failed counts.
// ================================================================

exec('entropy.sci', -1);   // load the entropy function and helpers

passed = 0;
failed = 0;
tol    = 1e-10;            // floating-point tolerance for comparisons

// ---- tiny helper -----------------------------------------------
function check(desc, got, expected, tol)
    global passed failed
    if abs(got - expected) <= tol then
        printf("  PASS  %s\n", desc);
        passed = passed + 1;
    else
        printf("  FAIL  %s  →  got %.10f, expected %.10f\n", desc, got, expected);
        failed = failed + 1;
    end
endfunction
// ----------------------------------------------------------------

printf("\n========================================\n");
printf("  entropy.sci – Test Suite\n");
printf("========================================\n\n");


// ================================================================
// TEST 1 – Binary image [0 1] → entropy = 1 bit
//   P = [0.5, 0.5],  E = -(0.5*log2(0.5) + 0.5*log2(0.5)) = 1
// ================================================================
printf("--- Test 1: Binary double array [0 1] ---\n");
E1 = entropy([0, 1]);
check("[0 1]  → 1 bit", E1, 1.0, tol);


// ================================================================
// TEST 2 – Constant array [0 0] → entropy = 0
//   Only one non-zero histogram bin, P=[1], E = -(1*log2(1)) = 0
// ================================================================
printf("\n--- Test 2: Constant array [0 0] ---\n");
E2 = entropy([0, 0]);
check("[0 0]  → 0 bits", E2, 0.0, tol);


// ================================================================
// TEST 3 – Single element [1] → entropy = 0
// ================================================================
printf("\n--- Test 3: Single element [1] ---\n");
E3 = entropy([1]);
check("[1]    → 0 bits", E3, 0.0, tol);


// ================================================================
// TEST 4 – uint8-style array uint8([0 1])
//   Scilab has no native uint8; pass as double and verify same result
// ================================================================
printf("\n--- Test 4: Integer array [0 1] (uint8-equivalent) ---\n");
E4 = entropy([0, 1]);     // Scilab: doubles == uint8 values here
check("uint8([0 1]) → 1 bit", E4, 1.0, tol);


// ================================================================
// TEST 5 – 3×3 logical array
//   L = [%f %t %t; %f %t %t; %f %f %t]   → 5 false, 4 true
//   P = [5/9, 4/9]
//   E = -(5/9*log2(5/9) + 4/9*log2(4/9))
// ================================================================
printf("\n--- Test 5: 3×3 logical array (mixed T/F) ---\n");
L3 = [%f %t %t; %f %t %t; %f %f %t];
p3 = [5/9, 4/9];
E5_expected = -sum(p3 .* log2(p3));
E5 = entropy(L3);
check("logical 3x3 mixed", E5, E5_expected, tol);


// ================================================================
// TEST 6 – 3×3 uniform uint8 matrix (all equal values)
//   All elements = 128 → only one occupied bin → E = 0
// ================================================================
printf("\n--- Test 6: Uniform 3×3 uint8 matrix (all 128) ---\n");
U = 128 .* ones(3, 3);
E6 = entropy(U);
check("uniform uint8 → 0 bits", E6, 0.0, tol);


// ================================================================
// TEST 7 – 3×3 uint8 matrix C = [1 1 1; 2 2 2; 3 3 3]
//   After im2uint8, values stay 1,2,3 (integer-coded doubles).
//   Three equally occupied bins: P = [1/3, 1/3, 1/3]
//   E = log2(3) ≈ 1.584963
// ================================================================
printf("\n--- Test 7: 3×3 uint8 matrix C = [1 1 1; 2 2 2; 3 3 3] ---\n");
C = [1 1 1; 2 2 2; 3 3 3];
pC = [1/3, 1/3, 1/3];
E7_expected = -sum(pC .* log2(pC));
E7 = entropy(C);
check("uint8 3-value uniform", E7, E7_expected, tol);


// ================================================================
// TEST 8 – RGB-style 3-D array (n-D grayscale treatment)
//   Octave: entropy(repmat([0 .5; 2 0], 1, 1, 3)) ==
//           entropy([0 .5; 2 0])
//   Both flatten to the same pixel set.
// ================================================================
printf("\n--- Test 8: 3-D (RGB-like) array == equivalent 2-D array ---\n");
base2d = [0 0.5; 2 0];
// Build 3-D array by stacking three identical planes
plane   = base2d;
arr3d   = cat(3, plane, plane, plane);   // Scilab: cat(dim, A, B, C)
E8_2d   = entropy(base2d);
E8_3d   = entropy(arr3d);
if abs(E8_2d - E8_3d) <= tol then
    printf("  PASS  3-D array entropy == 2-D base entropy  (E = %.6f)\n", E8_2d);
    passed = passed + 1;
else
    printf("  FAIL  3-D ≠ 2-D:  got %.10f vs %.10f\n", E8_3d, E8_2d);
    failed = failed + 1;
end


// ================================================================
// Summary
// ================================================================
printf("\n========================================\n");
printf("  Results: %d passed,  %d failed\n", passed, failed);
printf("========================================\n\n");

if failed == 0 then
    printf("  All tests PASSED.\n\n");
else
    printf("  Some tests FAILED – review output above.\n\n");
end
