// Load the roicolor function
exec("roicolor.sci", -1);

disp("===========================================");
disp("        ROICOLOR FUNCTION TEST CASES       ");
disp("===========================================");

// --- TEST CASE 1: Basic 1D Array Range ---
disp("--- TEST CASE 1: 1D Array Range (low=2, high=4) ---");
A1 = 1:6;
out1 = roicolor(A1, 2, 4);
disp("A = " + sci2exp(A1));
disp("Output BW:");
disp(out1);

// --- TEST CASE 2: Basic 2D Matrix Range ---
disp("--- TEST CASE 2: 2D Matrix Range (low=3, high=5) ---");
A2 = [1 2 3; 4 5 6];
out2 = roicolor(A2, 3, 5);
disp("Output BW:");
disp(out2);

// --- TEST CASE 3: Range acting as a Single Value ---
disp("--- TEST CASE 3: Range targeting single value (low=3, high=3) ---");
A3 = [1 2; 3 4];
out3 = roicolor(A3, 3, 3);
disp("Output BW:");
disp(out3);

// --- TEST CASE 4: Discrete Vector Matching ---
disp("--- TEST CASE 4: Vector matching (v=[1, 4]) ---");
A4 = [1 2; 3 4];
out4 = roicolor(A4, [1, 4]);
disp("Output BW:");
disp(out4);

// --- TEST CASE 5: Multiple Scattered Vector Matching ---
disp("--- TEST CASE 5: Vector matching scattered values (v=[2, 5, 8]) ---");
A5 = 1:10;
out5 = roicolor(A5, [2, 5, 8]);
disp("Output BW:");
disp(out5);

// --- TEST CASE 6: uint8 Image-Like Matrix ---
disp("--- TEST CASE 6: uint8 matrix range (low=100, high=200) ---");
A6 = uint8([10 50 100; 150 200 250]);
out6 = roicolor(A6, 100, 200);
disp("Output BW:");
disp(out6);

// --- TEST CASE 7: Empty Match (Range out of bounds) ---
disp("--- TEST CASE 7: Empty match range (low=10, high=20) ---");
A7 = [1 2; 3 4];
out7 = roicolor(A7, 10, 20);
disp("Output BW:");
disp(out7);

// --- TEST CASE 8: Empty Match (Vector out of bounds) ---
disp("--- TEST CASE 8: Empty match vector (v=[6, 7]) ---");
A8 = [1 2; 3 4];
out8 = roicolor(A8, [6, 7]);
disp("Output BW:");
disp(out8);

// --- TEST CASE 9: Floating Point Numbers ---
disp("--- TEST CASE 9: Floating point matrix (low=0.4, high=0.6) ---");
A9 = [0.1 0.5; 0.9 0.4];
out9 = roicolor(A9, 0.4, 0.6);
disp("Output BW:");
disp(out9);

// --- TEST CASE 10: Error Handling (Invalid Range Scalars) ---
disp("--- TEST CASE 10: Error Handling (low/high not scalars) ---");
try
    roicolor([1 2; 3 4], [1 2], [3 4]);
    disp("Failed: Should have thrown an error.");
catch
    [error_msg] = lasterror();
    disp("Successfully caught error: " + error_msg);
end

