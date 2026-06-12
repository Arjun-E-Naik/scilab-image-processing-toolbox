exec("applylut.sci",-1);




// ---- Define Standard 3x3 Look-Up Tables (LUTs) ----
LUT_ones = zeros(512, 1);
LUT_ones(512) = 1;

LUT_inv = ones(512, 1);
LUT_inv(512) = 0;

LUT_center = zeros(512, 1);
LUT_center(17) = 1;

LUT_line = zeros(512, 1);
LUT_line(147) = 1;

printf("========== Starting  Scilab applylut Tests ==========\n\n");

// Test 1
printf("Test 1: Alternating 3x3 Matrix (Should output all 0s with an all-ones LUT):\n");
BW1 = [%f, %t, %f; %t, %f, %t; %f, %t, %f];
disp(applylut(BW1, LUT_ones));
printf("\n");

// Test 2
printf("Test 2: All-Ones 3x3 Matrix (Center should hit index 512 and output 1):\n");
BW2 = ones(3, 3) == 1;
disp(applylut(BW2, LUT_ones));
printf("\n");

// Test 3
printf("Test 3: Rectangular 4x5 Matrix (Should handle non-square shapes seamlessly):\n");
BW3 = zeros(4, 5) == 1;
disp(applylut(BW3, LUT_ones));
printf("\n");

// Test 4
printf("Test 4: Inversion LUT on All-Ones (The center should flip from 1 to 0):\n");
BW4 = ones(3, 3) == 1;
disp(applylut(BW4, LUT_inv));
printf("\n");

// Test 5
printf("Test 5: Isolated Center Pixel (Should output a 1 precisely in the center):\n");
BW5 = [%f, %f, %f; %f, %t, %f; %f, %f, %f];
disp(applylut(BW5, LUT_center));
printf("\n");

// Test 6
printf("Test 6: Border Padding Check (5x5 of ones -> only the inner 3x3 core outputs 1):\n");
BW6 = ones(5, 5) == 1;
disp(applylut(BW6, LUT_ones));
printf("\n");

// Test 7
printf("Test 7: Horizontal Line Detection (Matches middle row via column-major indexing):\n");
BW7 = [%f, %f, %f, %f; %t, %t, %t, %t; %f, %f, %f, %f; %f, %f, %f, %f];
disp(applylut(BW7, LUT_line));
printf("\n");

