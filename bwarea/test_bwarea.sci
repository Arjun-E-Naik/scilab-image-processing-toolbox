
exec('bwarea.sci', -1);

printf(" bwarea Scilab Test Suite\n");
printf("=================================================================\n\n");

// TEST 1: Empty Image (All zeros)
disp("TEST 1: All zeros (3x3)");
disp(zeros(3,3));
disp("Output area:");
disp(bwarea(zeros(3,3)));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 2: Single Pixel
disp("TEST 2: Single pixel in matrix");
bw2 = zeros(3,3); bw2(2,2) = 1;
disp(bw2);
disp("Output area:");
disp(bwarea(bw2));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 3: 2x2 Square
disp("TEST 3: 2x2 Solid Square");
bw3 = zeros(4,4); bw3(2:3, 2:3) = 1;
disp(bw3);
disp("Output area:");
disp(bwarea(bw3));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 4: 1x3 Line
disp("TEST 4: 1x3 Straight Line");
bw4 = zeros(3,5); bw4(2, 2:4) = 1;
disp(bw4);
disp("Output area:");
disp(bwarea(bw4));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 5: 3x3 Solid Square (Touching bounds)
disp("TEST 5: 3x3 Solid Square (No padding)");
disp(ones(3,3));
disp("Output area:");
disp(bwarea(ones(3,3)));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 6: Diagonal Pixels (Identity Matrix)
disp("TEST 6: 2x2 Diagonal pixels (Identity)");
bw6 = eye(2,2);
disp(bw6);
disp("Output area:");
disp(bwarea(bw6));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 7: Numeric/Non-logical handling
disp("TEST 7: Numeric non-logical array (clamped to true)");
bw7 = [0 5 0; 0 -2 0; 0 0 0];
disp(bw7);
disp("Output area:");
disp(bwarea(bw7));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 8: 1x4 Line
disp("TEST 8: 1x4 Straight Line");
bw8 = zeros(3,6); bw8(2, 2:5) = 1;
disp(bw8);
disp("Output area:");
disp(bwarea(bw8));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 9: 2x3 Rectangle
disp("TEST 9: 2x3 Solid Rectangle");
bw9 = ones(2,3);
disp(bw9);
disp("Output area:");
disp(bwarea(bw9));
printf("\n-----------------------------------------------------------------\n\n");

// TEST 10: Dimension checking
disp("TEST 10: 3D matrix dimension error check");
disp("Input: ones(2,2,2)");
try
    bwarea(ones(2,2,2));
    disp("Output area: (Executed without system crash)");
catch
    disp("Output area: (Error successfully caught for 3D matrix)");
end


