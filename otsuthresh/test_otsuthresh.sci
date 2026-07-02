
exec("otsuthresh.sci",-1);

// Test 1: Simple 4-bin histogram (bimodal, clear threshold)

disp("Test 1: Simple 4-bin histogram");
h1 = [10, 2, 2, 10];
t1 = otsuthresh(h1);
disp("Input:    [10, 2, 2, 10]");
disp("Output:   " + string(t1));
disp(" ----------------------------------------------------");


// Test 2: 5-bin histogram with gradual slope

disp("Test 2: 5-bin histogram with gradual slope");
h2 = [8, 6, 4, 6, 8];
t2 = otsuthresh(h2);
disp("Input:    [8, 6, 4, 6, 8]");
disp("Output:   " + string(t2));
disp(" ----------------------------------------------------");


// Test 3: 6-bin histogram (single peak at start)

disp("Test 3: 6-bin histogram (single peak at start)");
h3 = [20, 5, 3, 2, 1, 1];
t3 = otsuthresh(h3);
disp("Input:    [20, 5, 3, 2, 1, 1]");
disp("Output:   " + string(t3));
disp(" ----------------------------------------------------");


// Test 4: 3-bin histogram (minimal case)

disp("Test 4: 3-bin histogram (minimal case)");
h4 = [5, 1, 5];
t4 = otsuthresh(h4);
disp("Input:    [5, 1, 5]");
disp("Output:   " + string(t4));
disp(" ----------------------------------------------------");


// Test 5: 8-bin uniform distribution

disp("Test 5: 8-bin uniform distribution");
h5 = [3, 3, 3, 3, 3, 3, 3, 3];
t5 = otsuthresh(h5);
disp("Input:    [3, 3, 3, 3, 3, 3, 3, 3]");
disp("Output:   " + string(t5));
disp(" ----------------------------------------------------");


// Test 6: 7-bin with two clear groups

disp("Test 6: 7-bin with two clear groups");
h6 = [15, 12, 1, 0, 0, 8, 10];
t6 = otsuthresh(h6);
disp("Input:    [15, 12, 1, 0, 0, 8, 10]");
disp("Output:   " + string(t6));
disp(" ----------------------------------------------------");


// Test 7: Single element histogram (degenerate case)

disp("Test 7: Single element histogram (degenerate case)");
h7 = [5];
t7 = otsuthresh(h7);
disp("Input:    [5]");
disp("Output:   " + string(t7));
disp(" ----------------------------------------------------");


// Test 8: 2-bin histogram

disp("Test 8: 2-bin histogram");
h8 = [3, 7];
t8 = otsuthresh(h8);
disp("Input:    [3, 7]");
disp("Output:   " + string(t8));
disp(" ----------------------------------------------------");

// ============================================================
// Error Handling Tests with Try-Catch
// ============================================================


// Error Test 1: Empty vector

disp("Error Test 1: Empty vector");
try
    te1 = otsuthresh([]);
    disp("Output:   " + string(te1));
catch
    disp("CAUGHT ERROR: " + lasterror());
end
disp(" ----------------------------------------------------");


// Error Test 2: Negative values in histogram

disp("Error Test 2: Negative values in histogram");
try
    te2 = otsuthresh([2, -1, 5, 3]);
    disp("Output:   " + string(te2));
catch
    disp("CAUGHT ERROR: " + lasterror());
end
disp(" ----------------------------------------------------");


// Error Test 3: Non-integer values in histogram

disp("Error Test 3: Non-integer values in histogram");
try
    te3 = otsuthresh([2.5, 3.1, 4.0, 1.2]);
    disp("Output:   " + string(te3));
catch
    disp("CAUGHT ERROR: " + lasterror());
end
disp(" ----------------------------------------------------");


// Error Test 4: 2D matrix input (wrong dimension)

disp("Error Test 4: 2D matrix input (wrong dimension)");
try
    te4 = otsuthresh([1, 2; 3, 4]);
    disp("Output:   " + string(te4));
catch
    disp("CAUGHT ERROR: " + lasterror());
end
disp(" ----------------------------------------------------");