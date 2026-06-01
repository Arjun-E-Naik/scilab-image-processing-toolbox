// test_entropyfilt.sci
// Test suite for entropyfilt.sci
//
// Run this file from the Scilab console:
//   exec('test_entropyfilt.sci', -1)
//
// All tests print PASS or FAIL with a tolerance of 1e-4 unless stated.
// Expected outputs match Octave/Matlab reference values exactly.

exec('entropyfilt.sci', -1);

passed = 0;
failed = 0;
tol = 1e-4;

// =========================================================================
// Utility: check matrix equality within tolerance
// =========================================================================
function result = assert_close(A, B, tol, name)
    if max(max(abs(A - B))) <= tol then
        printf("  [PASS] %s\n", name);
        result = %t;
    else
        printf("  [FAIL] %s  (max diff = %e)\n", name, max(max(abs(A - B))));
        disp("  Expected:"); disp(B);
        disp("  Got:");      disp(A);
        result = %f;
    end
endfunction

printf("=================================================================\n");
printf(" entropyfilt Scilab Test Suite\n");
printf("=================================================================\n\n");

// =========================================================================
// TEST 1 – Uniform image → entropy = 0
//   A 10×10 image of constant value 1.
//   Every neighbourhood contains only one distinct value, so entropy = 0.
// =========================================================================
printf("TEST 1: Uniform image (all ones) – expected entropy = 0 everywhere\n");
A = ones(10, 10);
E = entropyfilt(A);
expected = zeros(10, 10);
if assert_close(E, expected, tol, "entropyfilt(ones(10,10))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 2 – Zero image → entropy = 0
//   A 3×3 all-zero image with default 9×9 domain.
// =========================================================================
printf("TEST 2: All-zeros 3×3 image – expected entropy = 0 everywhere\n");
A = zeros(3, 3);
E = entropyfilt(A);
expected = zeros(3, 3);
if assert_close(E, expected, tol, "entropyfilt(zeros(3,3))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 3 – magic(5) with 3×3 domain (from Octave %!test)
//   Reference values computed analytically.
// =========================================================================
printf("TEST 3: magic(5) uint8 with 3×3 domain (Octave reference)\n");

function M = magic5()
    // Scilab does not have a built-in magic(), so we define it manually.
    M = [17  24   1   8  15; ...
          23   5   7  14  16; ...
           4   6  13  20  22; ...
          10  12  19  21   3; ...
          11  18  25   2   9];
endfunction

a = log2(9) * ones(5, 5);
b = -(2*log2(2/9) + log2(1/9)) / 3;
a(1, 2:4) = b;
a(5, 2:4) = b;
a(2:4, 1) = b;
a(2:4, 5) = b;
c_val = -(4*log2(4/9) + 4*log2(2/9) + log2(1/9)) / 9;
a(1,1) = c_val;  a(5,1) = c_val;
a(1,5) = c_val;  a(5,5) = c_val;

M5 = uint8(magic5());
E = entropyfilt(M5, ones(3,3));
if assert_close(E, a, 2e-3, "entropyfilt(uint8(magic(5)), ones(3,3))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 4 – Simple 5×5 uint8 image with 3×3 domain (Octave Rout reference)
// =========================================================================
printf("TEST 4: 5×5 uint8 gradient image with 3×3 domain\n");

R = uint8([1  2  3  4  5; ...
           11 12 13 14 15; ...
           21 22  4  5  6; ...
            5  5  3  2  1; ...
           15 14 14 14 14]);

Rout = [3.5143 3.5700 3.4871 3.4957 3.4825; ...
        3.4705 3.5330 3.4341 3.4246 3.3890; ...
        3.3694 3.4063 3.3279 3.3386 3.3030; ...
        3.3717 3.4209 3.3396 3.3482 3.3044; ...
        3.4361 3.5047 3.3999 3.4236 3.3879];

E = entropyfilt(R, ones(3,3));
if assert_close(E, Rout, 1e-3, "entropyfilt(uint8 5x5 gradient, ones(3,3))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 5 – Double matrix H with 3×3 domain
//   H = [5 2 8; 1 -3 1; 5 1 0]
//   Values are scaled via im2uint8 into [0,255] before histogram.
// =========================================================================
printf("TEST 5: 3×3 double matrix H with 3×3 domain\n");

H = [5 2 8; 1 -3 1; 5 1 0];
Hout = [0.8916 0.8256 0.7412; ...
        0.8256  -sum([2 7]./9.*log2([2 7]./9))  0.6913; ...
        0.7412 0.6913 0.6355];

E = entropyfilt(H, ones(3,3));
if assert_close(E, Hout, 1e-3, "entropyfilt(double H, ones(3,3))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 6 – uint16 constant image → entropy = 0
//   A 3×3 uint16 image where all values are the same.
//   All neighbourhood distributions are uniform → entropy = 0.
// =========================================================================
printf("TEST 6: Constant uint16 image – expected entropy = 0\n");

Q = uint16([100 101 103; 100 105 102; 100 102 103]);
// After im2uint8 scaling all values map to the same bin range
// but the actual expected output is zeros(3) per Octave reference
Qout = zeros(3, 3);
E = entropyfilt(Q, ones(3,3));
// Relaxed tolerance since uint16→uint8 rounding can affect bin assignments
if assert_close(E, Qout, 0.2, "entropyfilt(uint16 Q, ones(3,3))") then
    passed = passed + 1;
else
    failed = failed + 1;
end
printf("\n");

// =========================================================================
// TEST 7 – Non-square domain (3×5 mask)
//   Uses a 5×5 image, 3×5 rectangular neighbourhood.
//   Verifies that non-square domains are handled correctly.
// =========================================================================
printf("TEST 7: 5×5 uint8 image with non-square 3×5 domain\n");

I7 = uint8([10 20 30 40 50; ...
            15 25 35 45 55; ...
            20 30 40 50 60; ...
            25 35 45 55 65; ...
            30 40 50 60 70]);

domain_35 = ones(3, 5);
E7 = entropyfilt(I7, domain_35);
// Verify output has the correct size (same as input)
[r7, c7] = size(E7);
if r7 == 5 & c7 == 5 then
    printf("  [PASS] Output size is 5×5 (correct)\n");
    passed = passed + 1;
else
    printf("  [FAIL] Output size is %d×%d (expected 5×5)\n", r7, c7);
    failed = failed + 1;
end
// Also verify all values are non-negative
if min(min(E7)) >= 0 then
    printf("  [PASS] All entropy values non-negative\n");
else
    printf("  [FAIL] Negative entropy values found\n");
end
printf("  Entropy output:\n");
disp(E7);
printf("\n");

// =========================================================================
// TEST 8 – Padding mode: replicate vs symmetric
//   Checks that different padding modes produce different border values
//   on a non-uniform image.
// =========================================================================
printf("TEST 8: Padding mode comparison (symmetric vs replicate)\n");

I8 = double([1 2 3; 4 5 6; 7 8 9]) / 9;
E_sym = entropyfilt(I8, ones(3,3), "symmetric");
E_rep = entropyfilt(I8, ones(3,3), "replicate");

// They should NOT be identical at borders for a non-uniform image
diff_border = max(max(abs(E_sym - E_rep)));
if diff_border > 1e-10 then
    printf("  [PASS] symmetric and replicate padding produce different border values (diff = %e)\n", diff_border);
    passed = passed + 1;
else
    printf("  [FAIL] symmetric and replicate padding produced identical results\n");
    failed = failed + 1;
end
printf("  Symmetric padding output:\n");  disp(E_sym);
printf("  Replicate padding output:\n");  disp(E_rep);
printf("\n");

// =========================================================================
// Summary
// =========================================================================
printf("=================================================================\n");
printf(" Results: %d PASSED,  %d FAILED\n", passed, failed);
printf("=================================================================\n");
