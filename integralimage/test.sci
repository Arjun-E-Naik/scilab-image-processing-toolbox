
exec("integralImage.sci", -1);

disp("====================================================");
disp("         INTEGRALIMAGE FUNCTION TEST CASES          ");
disp("====================================================");

// --- TEST 1: Scalar Value Upright ---
disp("--- TEST 1: Scalar Value (Upright) ---");
I1 = 10;
disp("Input Array:", I1);
disp("Output Matrix:", integralImage(I1));
disp("----------------------------------------------------");

// --- TEST 2: Scalar Value Rotated ---
disp("--- TEST 2: Scalar Value (Rotated) ---");
disp("Input Array:", I1);
disp("Output Matrix:", integralImage(I1, "rotated"));
disp("----------------------------------------------------");

// --- TEST 3: 2x2 Matrix Upright ---
disp("--- TEST 3: 2x2 Matrix (Upright) ---");
I3 = [1, 2; 3, 4];
disp("Input Array:", I3);
disp("Output Matrix:", integralImage(I3, "upright"));
disp("----------------------------------------------------");

// --- TEST 4: 2x2 Matrix Rotated ---
disp("--- TEST 4: 2x2 Matrix (Rotated) ---");
disp("Input Array:", I3);
disp("Output Matrix:", integralImage(I3, "rotated"));
disp("----------------------------------------------------");

// --- TEST 5: Default Orientation Parameter Omission ---
disp("--- TEST 5: Defaulting Omission (Should be Upright) ---");
I5 = [5, 5; 5, 5];
disp("Input Array:", I5);
disp("Output Matrix:", integralImage(I5));
disp("----------------------------------------------------");

// --- TEST 6: Type Casting from uint8 Matrix ---
disp("--- TEST 6: Type Casting (uint8 image matrix input) ---");
I6 = uint8([10, 20; 30, 40]);
disp("Input Data Type:", typeof(I6));
res6 = integralImage(I6);
disp("Output Data Type (Expected: constant/double):", typeof(res6));
disp("Output Matrix Values:", res6);
disp("----------------------------------------------------");

// --- TEST 7: 3D Hypermatrix Stack Upright ---
disp("--- TEST 7: 3D Hypermatrix Channel Stack (Upright) ---");
I7 = zeros(2, 2, 2);
I7(:,:,1) = [1, 2; 3, 4];
I7(:,:,2) = [5, 6; 7, 8];
disp("Input Stack Dimension:", size(I7));
res7 = integralImage(I7, "upright");
disp("Resulting Channel Layer 1 Output:", res7(:,:,1));
disp("Resulting Channel Layer 2 Output:", res7(:,:,2));
disp("----------------------------------------------------");

// --- TEST 8: 3D Hypermatrix Stack Rotated ---
disp("--- TEST 8: 3D Hypermatrix Channel Stack (Rotated) ---");
res8 = integralImage(I7, "rotated");
disp("Resulting Channel Layer 1 Output:", res8(:,:,1));
disp("Resulting Channel Layer 2 Output:", res8(:,:,2));
disp("----------------------------------------------------");

// --- TEST 9: Error Handling (Invalid Dimension / Arguments Count) ---
disp("--- TEST 9: Error Handling (Argn Mismatch Validation) ---");
try
    integralImage();
catch
    disp("Caught Expected Error: Empty inputs triggered error handler successfully.");
end
disp("----------------------------------------------------");

// --- TEST 10: Error Handling (String Input Class Mismatch) ---
disp("--- TEST 10: Error Handling (Image Matrix Validation) ---");
try
    integralImage("InvalidStringImageInput");
catch
    disp("Caught Expected Error: Non-numeric string matrix safely blocked.");
end
disp("====================================================");