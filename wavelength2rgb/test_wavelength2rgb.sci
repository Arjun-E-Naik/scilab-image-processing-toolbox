exec("wavelength2rgb.sci",-1);

disp("Test 1: Standard 1D Array (User Example)");
rgb_multi = wavelength2rgb([400, 410]);
// Expected: 1x2x3 hypermatrix of doubles
disp(rgb_multi);
disp(" ----------------------------------------------------");

disp("Test 2: Scalar Wavelength Default Args");
rgb_scalar = wavelength2rgb(400);
// Expected: 1x3 vector of doubles representing a violet/blue color
disp(rgb_scalar);
disp(" ----------------------------------------------------");

disp("Test 3: Wavelength Outside Vision Range (Black)");
rgb_out = wavelength2rgb(300);
// Expected: 1x3 vector of zeros (Black)
disp(rgb_out);
disp(" ----------------------------------------------------");

disp("Test 4: 2D Matrix Input");
rgb_matrix = wavelength2rgb([400 450; 500 550]);
// Expected: 2x2x3 hypermatrix of doubles
disp(rgb_matrix);
disp(" ----------------------------------------------------");

disp("Test 5: Upper Vision Limit Range");
rgb_upper = wavelength2rgb(750);
// Expected: 1x3 vector with a dimmed red value (due to vision falloff)
disp(rgb_upper);
disp(" ----------------------------------------------------");

disp("Test 6: Output Class uint8");
rgb_uint8 = wavelength2rgb(400, "uint8");
// Expected: 1x3 vector of uint8 integers (values clamped 0-255)
disp(rgb_uint8);
disp(" ----------------------------------------------------");

disp("Test 7: Output Class uint16");
rgb_uint16 = wavelength2rgb(500, "uint16");
// Expected: 1x3 vector of uint16 integers (values clamped 0-65535)
disp(rgb_uint16);
disp(" ----------------------------------------------------");

disp("Test 8: Output Class single");
rgb_single = wavelength2rgb(600, "single");
// Expected: 1x3 vector of singles (floating point)
disp(rgb_single);
disp(" ----------------------------------------------------");

disp("Test 9: Custom Gamma Adjustment");
rgb_gamma = wavelength2rgb(450, "double", 0.5);
// Expected: 1x3 vector of doubles with mathematically higher values due to 0.5 gamma curve
disp(rgb_gamma);
disp(" ----------------------------------------------------");

disp("Test 10: Multi-dimensional array with Custom Class and Gamma");
rgb_complex = wavelength2rgb([380 500 700], "int16", 1.0);
// Expected: 1x3x3 hypermatrix of int16 values with linear gamma
disp(rgb_complex);
disp(" ----------------------------------------------------");

disp("Error Test 1: Negative Wavelength Input");
try
    rgb_err1 = wavelength2rgb([-400, 500]);
    disp("FAIL: Did not catch error!");
catch
    [err_msg, err_code] = lasterror();
    // Expected: Error mentioning wavelength must be a positive numeric
    disp("Caught expected error:");
    disp(err_msg);
end
disp(" ----------------------------------------------------");

disp("Error Test 2: Invalid Output Class String");
try
    rgb_err2 = wavelength2rgb(450, "float64");
    disp("FAIL: Did not catch error!");
catch
    [err_msg, err_code] = lasterror();
    // Expected: Error mentioning unsupported class
    disp("Caught expected error:");
    disp(err_msg);
end
disp(" ----------------------------------------------------");

disp("Error Test 3: Gamma Value Out of Bounds");
try
    rgb_err3 = wavelength2rgb(500, "double", 1.5);
    disp("FAIL: Did not catch error!");
catch
    [err_msg, err_code] = lasterror();
    // Expected: Error mentioning gamma must be between 0 and 1
    disp("Caught expected error:");
    disp(err_msg);
end
disp(" ----------------------------------------------------");