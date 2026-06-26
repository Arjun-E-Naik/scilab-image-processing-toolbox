exec("applylut.sci",-1);





printf("========== Starting  Scilab applylut Tests ==========\n\n");

// Test 1
printf("Test 1: Alternating 3x3 Matrix (Should output all 0s with an all-ones LUT):\n");
function res = fun(idx)
    res = double(and(idx)); // Returns 1 only if ALL elements in the 3x3 grid are 1
endfunction

LUT = makelut(fun, 3);

BW1 = [%f, %t, %f; %t, %f, %t; %f, %t, %f];
disp(applylut(BW1, LUT));
printf("\n");

// Test 2
printf("Test 2: All-Ones 3x3 Matrix (Center should hit index 512 and output 1):\n");
function res = fun(idx)
    res = double(and(idx)); 
endfunction

LUT = makelut(fun, 3);

BW2 = ones(3, 3) == 1;
disp(applylut(BW2, LUT));
printf("\n");

// Test 3
printf("Test 3: Rectangular 4x5 Matrix (Should handle non-square shapes seamlessly):\n");
function res = fun(idx)
    res = double(and(idx)); 
endfunction

LUT = makelut(fun, 3);
BW3 = zeros(4, 5) == 1;
disp(applylut(BW3, LUT));
printf("\n");

// Test 4
function res = fun(idx)
    res = double(~and(idx));
endfunction
LUT = makelut(fun, 3);
BW4 = ones(3, 3) == 1;
disp(applylut(BW4, LUT));
printf("\n");

// Test 5
printf("Test 5: Isolated Center Pixel (Should output a 1 precisely in the center):\n");
LUT = zeros(512, 1);
LUT(17) = 1;
BW5 = [%f, %f, %f; %f, %t, %f; %f, %f, %f];
disp(applylut(BW5, LUT));
printf("\n");

// Test 6
printf("Test 6: Border Padding Check (5x5 of ones -> only the inner 3x3 core outputs 1):\n");
LUT = zeros(512, 1);
LUT(512) = 1;
BW6 = ones(5, 5) == 1;
disp(applylut(BW6, LUT));
printf("\n");

// Test 7
printf("Test 7: Horizontal Line Detection (Matches middle row via column-major indexing):\n");
LUT = zeros(512, 1);
LUT(147) = 1;
BW7 = [%f, %f, %f, %f;
       %t, %t, %t, %t;
       %f, %f, %f, %f;
       %f, %f, %f, %f];
disp(applylut(BW7, LUT));
printf("\n");

// Test 7
printf("Test 8: Error Handling:\n");
img = [1,0,1; 0,1,0; 1,0,1];
try
    applylut(img);
catch
    [msg, err] = lasterror();
    mprintf("Caught: %s\n", msg);
end
printf("\n");

// Test 7
printf("Test 9: Error Handlling:\n");
img = [1,0,1; 0,1,0; 1,0,1];
lut = zeros(100, 1); 
try
    applylut(img, lut);
catch
    [msg, err] = lasterror();
    mprintf("Caught: %s\n", msg);
end

printf("\n");
