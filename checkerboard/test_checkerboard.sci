exec("checkerboard.sci",-1);

mprintf("===========================================\n");
mprintf("    SCILAB CHECKERBOARD TEST SUITE         \n");
mprintf("===========================================\n\n");

mprintf("--- TEST 1: Basic Board (4x4 matrix) --- \n");
mprintf("checkerboard(1, 2)\n");
disp(checkerboard(1, 2));

mprintf("\n--- TEST 2: Rectangular Layout (8x12 matrix) --- \n");
mprintf("checkerboard(2, 2, 3)\n");
disp(checkerboard(2, 2, 3));

mprintf("\n--- TEST 3: 3D Matrix Quirk --- \n");
mprintf("size(checkerboard(1, 1, 1, 2))\n");
disp(size(checkerboard(1, 1, 1, 2)));

mprintf("\n--- TEST 4: Vector Sizing --- \n");
mprintf("size(checkerboard(1, [3, 2]))\n");
disp(size(checkerboard(1, [3, 2])));

mprintf("\n--- TEST 5: Side = 0 (Empty Matrix) --- \n");
mprintf("size(checkerboard(0, 3, 3))\n");
disp(size(checkerboard(0, 3, 3)));

mprintf("\n--- TEST 6: Dimension = 0 (Engine Limits) --- \n");
mprintf("size(checkerboard(2, 0, 3))\n");
disp(size(checkerboard(2, 0, 3)));



