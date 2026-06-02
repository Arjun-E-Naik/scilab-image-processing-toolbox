// test_entropyfilt.sci
// Test suite for entropyfilt.sci

exec('entropyfilt.sci', -1);

passed = 0;
failed = 0;
tol = 1e-4;

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

// TEST 1
printf("TEST 1: Uniform image (all ones)\n");
if assert_close(entropyfilt(ones(10, 10)), zeros(10, 10), tol, "entropyfilt(ones(10,10))") then passed = passed + 1; else failed = failed + 1; end
printf("\n");

// TEST 2
printf("TEST 2: All-zeros 3×3 image\n");
if assert_close(entropyfilt(zeros(3, 3)), zeros(3, 3), tol, "entropyfilt(zeros(3,3))") then passed = passed + 1; else failed = failed + 1; end
printf("\n");

// TEST 3
printf("TEST 3: magic(5) uint8 with 3×3 domain\n");
function M = magic5()
    M = [17  24   1   8  15; 23   5   7  14  16; 4   6  13  20  22; 10  12  19  21   3; 11  18  25   2   9];
endfunction
a = log2(9) * ones(5, 5);
b = -(2*log2(2/9) + log2(1/9)) / 3;
a(1, 2:4) = b; a(5, 2:4) = b; a(2:4, 1) = b; a(2:4, 5) = b;
c_val = -(4*log2(4/9) + 4*log2(2/9) + log2(1/9)) / 9;
a(1,1) = c_val;  a(5,1) = c_val; a(1,5) = c_val;  a(5,5) = c_val;
if assert_close(entropyfilt(uint8(magic5()), ones(3,3)), a, 2e-3, "entropyfilt(uint8(magic(5)), ones(3,3))") then passed = passed + 1; else failed = failed + 1; end
printf("\n");

// TEST 4 - FIXED DOMAIN TO 9x9 (OCTAVE DEFAULT)
printf("TEST 4: 5×5 uint8 gradient image with default 9×9 domain\n");
R = uint8([1  2  3  4  5; 11 12 13 14 15; 21 22  4  5  6; 5  5  3  2  1; 15 14 14 14 14]);
Rout = [3.5143 3.5700 3.4871 3.4957 3.4825; 
        3.4705 3.5330 3.4341 3.4246 3.3890; 
        3.3694 3.4063 3.3279 3.3386 3.3030; 
        3.3717 3.4209 3.3396 3.3482 3.3044; 
        3.4361 3.5047 3.3999 3.4236 3.3879];
if assert_close(entropyfilt(R, ones(9,9)), Rout, 1e-1, "entropyfilt(uint8 gradient, ones(9,9))") then passed = passed + 1; else failed = failed + 1; end
printf("\n");



// TEST 5
printf("TEST 5: Constant uint16 image\n");
Q = uint16([100 101 103; 100 105 102; 100 102 103]);
if assert_close(entropyfilt(Q, ones(3,3)), zeros(3, 3), 0.2, "entropyfilt(uint16 Q, ones(3,3))") then passed = passed + 1; else failed = failed + 1; end
printf("\n");

// TEST 6
printf("TEST 6: 5×5 uint8 image with non-square 3×5 domain\n");
I7 = uint8([10 20 30 40 50; 15 25 35 45 55; 20 30 40 50 60; 25 35 45 55 65; 30 40 50 60 70]);
E7 = entropyfilt(I7, ones(3, 5));
[r7, c7] = size(E7);
if r7 == 5 & c7 == 5 & min(min(E7)) >= 0 then
    printf("  [PASS] Output size is correct and non-negative\n");
    passed = passed + 1;
else
    printf("  [FAIL] Test 7 failed geometry/sign checks\n");
    failed = failed + 1;
end
printf("\n");

// TEST 7- FIXED TO 5x5 DOMAIN TO EXPOSE PADDING DIFFERENCE
printf("TEST 7: Padding mode comparison (symmetric vs replicate, 5x5 domain)\n");
I8 = double([1 2 3; 4 5 6; 7 8 9]) / 9;
E_sym = entropyfilt(I8, ones(5,5), "symmetric");
E_rep = entropyfilt(I8, ones(5,5), "replicate");
diff_border = max(max(abs(E_sym - E_rep)));
if diff_border > 1e-10 then
    printf("  [PASS] symmetric and replicate padding produce different border values (diff = %e)\n", diff_border);
    passed = passed + 1;
else
    printf("  [FAIL] symmetric and replicate padding produced identical results\n");
    failed = failed + 1;
end
printf("\n");

printf("=================================================================\n");
printf(" Results: %d PASSED,  %d FAILED\n", passed, failed);
printf("=================================================================\n");
