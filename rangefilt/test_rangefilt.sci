// test_rangefilt.sce
// Octave-resemblance Test Suite for rangefilt

exec('rangefilt.sci', -1);

passed = 0; 
failed = 0; 
tol = 1e-10; 

function result = assert_equal(A, B, tol, name)
    // Flatten arrays using (:) to guarantee a strict scalar comparison
    if max(abs(A(:) - B(:))) <= tol then
        printf("  [PASS] %s\n", name);
        result = %t;
    else
        printf("  [FAIL] %s\n", name);
        result = %f;
    end
endfunction

printf("=================================================================\n");
printf(" rangefilt Exact Octave-Translation Scilab Test Suite\n");
printf("=================================================================\n\n");

// TEST 1
im1 = rangefilt(ones(5, 5));
if assert_equal(im1, zeros(5, 5), tol, "TEST 1: rangefilt(ones(5))") then passed = passed + 1; else failed = failed + 1; end

// TEST 2
A = zeros(3,3); A_out = zeros(3,3);
if assert_equal(rangefilt(A), A_out, tol, "TEST 2: Zeros") then passed = passed + 1; else failed = failed + 1; end

// TEST 3
B = ones(3,3); B_out = zeros(3,3);
if assert_equal(rangefilt(B), B_out, tol, "TEST 3: Ones") then passed = passed + 1; else failed = failed + 1; end

// TEST 4
C = [1 1 1; 2 2 2; 3 3 3]; C_out = [1 1 1; 2 2 2; 1 1 1];
if assert_equal(rangefilt(C), C_out, tol, "TEST 4: Gradient Rows") then passed = passed + 1; else failed = failed + 1; end

// TEST 5
D = C'; D_out = [1 2 1; 1 2 1; 1 2 1];
if assert_equal(rangefilt(D), D_out, tol, "TEST 5: Gradient Cols") then passed = passed + 1; else failed = failed + 1; end

// TEST 6
E = ones(3,3); E(2,2) = 2; E_out = ones(3,3);
if assert_equal(rangefilt(E), E_out, tol, "TEST 6: Single center point (peak)") then passed = passed + 1; else failed = failed + 1; end

// TEST 7
F = 3 .* ones(3,3); F(2,2) = 1; F_out = 2 * ones(3,3);
if assert_equal(rangefilt(F), F_out, tol, "TEST 7: Single center point (depression)") then passed = passed + 1; else failed = failed + 1; end

// TEST 8
G = [-1 2 7; -5 2 8; -7 %pi 9]; G_out = [7 13 6; 7+%pi 16 7; 7+%pi 16 7];
if assert_equal(rangefilt(G), G_out, tol, "TEST 8: Decimals and Negatives (PI)") then passed = passed + 1; else failed = failed + 1; end

// TEST 9
H = [5 2 8; 1 -3 1; 5 1 0]; H_out = [8 11 11; 8 11 11; 8 8 4];
if assert_equal(rangefilt(H), H_out, tol, "TEST 9: Mixed signs") then passed = passed + 1; else failed = failed + 1; end

printf("\n=================================================================\n");
printf(" Results: %d PASSED,  %d FAILED\n", passed, failed);
printf("=================================================================\n");