// =============================================================================
// SCILAB INTLUT DIRECT PRINT TEST SUITE
// =============================================================================

exec("intlut.sci", -1);

mprintf("====================================================\n");
mprintf("      RUNNING SCILAB INTLUT OUTPUT DISPLAY          \n");
mprintf("====================================================\n\n");

function display_test(test_num, desc, actual)
    mprintf("--- TEST %02d: %s ---\n", test_num, desc);
    mprintf("Output Type: %s\n", typeof(actual));
    mprintf("Output Dimensions: %s\n", strcat(string(size(actual)), "x"));
    mprintf("Values:\n");
    disp(actual);
    mprintf("----------------------------------------------------\n\n");
endfunction

// Test 1: Vector uint8 conversion (Inversion mapping)
A1 = uint8([1, 2, 3, 4]);
LUT1 = uint8(255:-1:0);
display_test(1, "Basic uint8 Inversion Vector", intlut(A1, LUT1));

// Test 2: Vector uint16 conversion (Inversion mapping)
A2 = uint16([1, 2, 3, 4]);
LUT2 = uint16(65535:-1:0);
display_test(2, "Basic uint16 Inversion Vector", intlut(A2, LUT2));

// Test 3: Signed int16 mapping (Checks standard mapping offset)
A3 = int16([1, 2, 3, 4]);
LUT3 = int16(32767:-1:-32768);
display_test(3, "Basic int16 Negative-to-Positive Vector", intlut(A3, LUT3));

// Test 4: Identity Mapping on 2D Matrix (uint8)
A4 = uint8([0, 100; 200, 255]);
LUT4 = uint8(0:255);
display_test(4, "2D Matrix Identity Mapping (uint8)", intlut(A4, LUT4));

// Test 5: Boundary checks for uint8 (maps upper/lower bound elements to 42)
A5 = uint8([0, 255]);
LUT5 = uint8(ones(1, 256) * 42);
display_test(5, "uint8 Bound Caps Mapping (Expected all 42)", intlut(A5, LUT5));

// Test 6: Boundary checks for signed int16 extrema thresholds
A6 = int16([-32768, 32767]);
LUT6 = int16(-32768:32767);
display_test(6, "int16 Extreme Extrema Values Identity Mapping", intlut(A6, LUT6));

// Test 7: 3D Hypermatrix transformation validation
A7 = uint8(zeros(2, 2, 2));
A7(1,1,1) = 0; A7(2,2,2) = 255;
LUT7 = uint8(255:-1:0);
display_test(7, "3D Hypermatrix Mapping (uint8)", intlut(A7, LUT7));

// Test 8: Error handling - Mismatched variable types
mprintf("--- TEST 08: Class Mismatch Error Catching ---\n");
try
    intlut(uint16([1, 2]), uint8(0:255));
    mprintf("Result: Failed (No error raised)\n");
catch
    mprintf("Result: Passed (Caught mismatch error cleanly)\n");
end
mprintf("----------------------------------------------------\n\n");

// Test 9: Error handling - Invalid lookup table length
mprintf("--- TEST 09: Invalid LUT Length Catching ---\n");
try
    intlut(uint8([1, 2]), uint8(0:10));
    mprintf("Result: Failed (No error raised)\n");
catch
    mprintf("Result: Passed (Caught invalid size error cleanly)\n");
end
mprintf("----------------------------------------------------\n\n");

// Test 10: Error handling - 2D matrix supplied instead of vector LUT
mprintf("--- TEST 10: Non-Vector Dimension Table Check ---\n");
try
    intlut(uint8(56), uint8(zeros(16, 16)));
    mprintf("Result: Failed (No error raised)\n");
catch
    mprintf("Result: Passed (Caught 2D matrix restriction error cleanly)\n");
end
mprintf("====================================================\n");