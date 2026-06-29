exec("grayslice.sci",-1);

// ==================== 10 TEST CASES ====================

disp("Test Case 1: Basic scalar threshold partitioning (N=10)");
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, 10);
disp(ans);

disp("Test Case 2: Custom threshold vector V");
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]);
disp(ans);

disp("Test Case 3: Small uniform quantization (N=2)");
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, 2);
disp(ans);

disp("Test Case 4: Explicit vector thresholds including boundary conditions");
im = [0, 0.45, 0.5, 0.55, 1];
ans = grayslice(im, [0.5, 1]);
disp(ans);

disp("Test Case 5: Threshold vector with unsorted values");
im = [0, 0.5, 1];
ans = grayslice(im, [0, 1, 0.5]);
disp(ans);

disp("Test Case 6: Fractional scalar N between 0 and 1 acting as a single threshold");
im = [0, 0.5, 0.55, 0.7, 1];
ans = grayslice(im, 0.51);
disp(ans);

disp("Test Case 7: Threshold vector with repeated values");
im = [0, 0.45, 0.5, 0.65, 0.7, 1];
ans = grayslice(im, [0.4, 0.5, 0.5, 0.7, 0.7, 1]);
disp(ans);

disp("Test Case 8: Handling negative values and inputs outside the [0, 1] range");
im = [-0.5, 0.1, 0.8, 1.2];
ans = grayslice(im, [-1, -0.4, 0.05, 0.6, 0.9, 1.1, 2]);
disp(ans);

disp("Test Case 9: Automated type elevation to double when N >= 256");
im = uint8(0:255);
ans = typeof(grayslice(im, 256));
disp(ans);

disp("Test Case 10: Integer class (uint8) full range partitioning");
im = uint8([0, 100, 200, 255]);
ans = grayslice(im, [100, 199, 200, 210]);
disp(ans);
