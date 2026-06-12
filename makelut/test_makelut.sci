exec("makelut.sci",-1);


// Test Case 01


disp("Test Case :01");

function y = center_pixel(x)
    y = x(5);
endfunction

lut = makelut(center_pixel,3);

disp(lut(1:16));
disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 02


disp("Test Case :02");

function y = always_zero(x)
    y = 0;
endfunction

lut = makelut(always_zero,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 03


disp("Test Case :03");

function y = always_one(x)
    y = 1;
endfunction

lut = makelut(always_one,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 04


disp("Test Case :04");

function y = majority(x)
    y = (sum(x(:)) >= 5);
endfunction

lut = makelut(majority,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 05


disp("Test Case :05");

function y = single_pixel(x)
    y = (sum(x(:)) == 1);
endfunction

lut = makelut(single_pixel,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 06


disp("Test Case :06");

function y = all_on(x)
    y = and(x(:));
endfunction

lut = makelut(all_on,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 07


disp("Test Case :07");

function y = any_on(x)
    y = or(x(:));
endfunction

lut = makelut(any_on,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 08


disp("Test Case :08");

function y = corner(x)
    y = x(1);
endfunction

lut = makelut(corner,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 09


disp("Test Case :09");

function y = parity(x)
    y = (modulo(sum(x(:)),2) == 0);
endfunction

lut = makelut(parity,3);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));


// Test Case 10


disp("Test Case :10");

function y = rule2(x)
    y = (sum(x(:)) >= 2);
endfunction

lut = makelut(rule2,2);

disp("LUT Length:");
disp(length(lut));

disp("LUT Sum:");
disp(sum(lut));

disp("Unique Values:");
disp(unique(lut));