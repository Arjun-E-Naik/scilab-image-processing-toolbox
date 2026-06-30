
exec('fftconv2.sci', -1);


disp("Test 1: 2x2 with 2x2, full");
a = [1 2; 3 4];
b = [1 0; 0 1];
result = fftconv2(a, b, "full");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 3x3, identity-like convolution
disp(" ----------------------------------------------------");


// Test 2: 2×3 with 3×2, "full" shape

disp("Test 2: 2x3 with 3x2, full");
a = [1 2 3; 4 5 6];
b = [1 1; 1 1; 1 1];
result = fftconv2(a, b, "full");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 4x4
disp(" ----------------------------------------------------");


// Test 3: 3×3 with 3×3, "same" shape

disp("Test 3: 3x3 with 3x3, same");
a = [1 0 0; 0 1 0; 0 0 1];
b = [1 1 1; 1 1 1; 1 1 1];
result = fftconv2(a, b, "same");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 3x3
disp(" ----------------------------------------------------");


// Test 4: 3×3 with 2×2, "valid" shape

disp("Test 4: 3x3 with 2x2, valid");
a = [1 2 3; 4 5 6; 7 8 9];
b = [1 0; 0 1];
result = fftconv2(a, b, "valid");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 2x2
disp(" ----------------------------------------------------");


// Test 5: 2×2 with 2×2, "same" shape

disp("Test 5: 2x2 with 2x2, same");
a = [2 3; 4 5];
b = [1 2; 3 4];
result = fftconv2(a, b, "same");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 2x2
disp(" ----------------------------------------------------");


// Test 6: 1×4 row vector with 4×1 column vector, "full"

disp("Test 6: 1x4 row with 4x1 col, full");
a = [1 2 3 4];
b = [1; 2; 3; 4];
result = fftconv2(a, b, "full");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 4x4
disp(" ----------------------------------------------------");


// Test 7: 4×1 column with 1×4 row, "full"

disp("Test 7: 4x1 col with 1x4 row, full");
a = [1; 2; 3; 4];
b = [1 2 3 4];
result = fftconv2(a, b, "full");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 4x4
disp(" ----------------------------------------------------");


// Test 8: 2×3 with 2×3, "valid" shape

disp("Test 8: 2x3 with 2x3, valid");
a = [1 2 3; 4 5 6];
b = [1 0 1; 0 1 0];
result = fftconv2(a, b, "valid");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 1x2 (empty if sizes equal: 2-2+1=1, 3-3+1=1, so 1x1)
disp(" ----------------------------------------------------");


// Test 9: Single element (1×1) with 3×3, "full"

disp("Test 9: 1x1 with 3x3, full");
a = [5];
b = [1 2 3; 4 5 6; 7 8 9];
result = fftconv2(a, b, "full");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 3x3 (scaled by 5)
disp(" ----------------------------------------------------");


// Test 10: 3×3 with 1×1, "same"

disp("Test 10: 3x3 with 1x1, same");
a = [1 2 3; 4 5 6; 7 8 9];
b = [3];
result = fftconv2(a, b, "same");
disp("Size: " + string(size(result,1)) + "x" + string(size(result,2)));
disp(result);
// Expected: 3x3 (scaled by 3)
disp(" ----------------------------------------------------");

// Error Handling Tests with try-catch



// Error Test 1: Less than 2 input arguments

disp("Error Test 1: Less than 2 input arguments");
try
    result_err = fftconv2([1, 2]);
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
disp(" ----------------------------------------------------");


// Error Test 2: Invalid shape parameter

disp("Error Test 2: Invalid shape parameter");
try
    a = ones(5, 5);
    b = ones(3, 3);
    result_err = fftconv2(a, b, "invalid_shape");
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
disp(" ----------------------------------------------------");


// Error Test 3: Non-numeric third argument in 3-argument form

disp("Error Test 3: Non-numeric third argument in 3-argument form");
try
    x = 1:4;
    y = 4:-1:1;
    a = "not_a_matrix";
    result_err = fftconv2(x, y, a);
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
disp(" ----------------------------------------------------");


// End of Test Suite

disp("All tests completed.");