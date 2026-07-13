
exec("integralimage3.sci", -1);

// ========== Test Case 1: Basic 2x2 grayscale image ==========
I1 = [1 2; 3 4];
disp("Test 1: Basic 2x2 grayscale");
disp(integralImage3(I1));

// ========== Test Case 2: 3D RGB-like image (2x2x3) ==========
I2 = zeros(2,2,3);
I2(:,:,1) = [1 2; 3 4];
I2(:,:,2) = [5 6; 7 8];
I2(:,:,3) = [9 10; 11 12];
disp("Test 2: 3D RGB-like 2x2x3");
disp(integralImage3(I2));

// ========== Test Case 3: Single pixel image ==========
I3 = [42];
disp("Test 3: Single pixel");
disp(integralImage3(I3));

// ========== Test Case 4: zero matrix ==========
I4 = zeros(2, 2, 2);
disp("Test 4: All-zero 3D matrix (2x2x2)");
disp(integralImage3(I4));

// ========== Test Case 5: Column vector (4x1) ==========
I5 = [1; 2; 3; 4];
disp("Test 5: Column vector 4x1");
disp(integralImage3(I5));

// ========== Test Case 6: 3x3 with zeros and negatives ==========
I6 = [0 -1 2; 3 0 -4; 5 6 0];
disp("Test 6: 3x3 with zeros and negatives");
disp(integralImage3(I6));

// ========== Test Case 7: Logical/boolean input ==========
I7 = [%T %F %T; %F %T %F; %T %T %T];
disp("Test 7: Logical 3x3 input");
disp(integralImage3(I7));

// ========== Test Case 8: Integer input (int8) ==========
I8 = int8([1 2 3; 4 5 6]);
disp("Test 8: int8 2x3 input");
disp(integralImage3(I8));

// ========== Test Case 9: Multi-frame 3D (2x3x4) ==========
I9 = matrix(1:24, 2, 3, 4);
disp("Test 9: Multi-frame 2x3x4");
disp(integralImage3(I9));

// ========== Test Case 10: Larger 2D with floating point ==========
I10 = [0.5 1.5 2.5; 3.5 4.5 5.5; 6.5 7.5 8.5; 9.5 10.5 11.5];
disp("Test 10: 4x3 floating point");
disp(integralImage3(I10));
