exec("psnr.sci",-1);

disp("Test cases for PSNR function");

disp("Test case :01");
A   = uint8([100 150 200; 50 75 25]);
ref = uint8([100 150 200; 50 75 25]);
p   = psnr(A, ref);
disp(p);
// MSE = 0  →  PSNR = +Inf

disp("Test case :02");
A   = uint8(zeros(2,2));      // all zeros
ref = uint8(255 * ones(2,2)); // all 255
p   = psnr(A, ref);
disp(p); 

disp("Test case :03");
A   = zeros(2,2);
ref = ones(2,2);
p   = psnr(A, ref);
disp(p);

disp("Test case :04");
A   = [0];
ref = [128];
p   = psnr(A, ref, 256);
disp(p);

disp("Test case :05");
A   = [10 20; 30 40];
ref = [12 18; 32 38];
[p, s] = psnr(A, ref);
disp(p);
disp(s);

disp("Test case :06");
A   = uint16([0]);
ref = uint16([32768]);
p   = psnr(A, ref);
disp(p);
