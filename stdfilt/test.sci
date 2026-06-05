exec("stdfilt.sci",-1);

disp("Test Case:01");
A = ones(5, 5);
S = stdfilt(A);
disp(S);


disp("Test Case:03");
A = zeros(4, 4);
S = stdfilt(A);
disp(S);


disp("Test Case:03");
M = uint8([17 24  1  8 15;
           23  5  7 14 16;
            4  6 13 20 22;
           10 12 19 21  3;
           11 18 25  2  9]);

S = stdfilt(M, ones(3,3));
disp(S);


disp("Test Case:04");
R = uint8([ 1  2  3  4  5;
           11 12 13 14 15;
           21 22  4  5  6;
            5  5  3  2  1;
           15 14 14 14 14]);

S = stdfilt(R, ones(3,3));
disp(S);


disp("Test Case:05");
A = [1 2 3 4 5];
S = stdfilt(A, ones(1, 3));
disp(S);


disp("Test Case:06");
I = uint8([1 2 3; 4 5 6; 7 8 9]);
S = stdfilt(I, [0 0 0; 0 1 0; 0 0 0]);  // single active pixel
disp(S);


disp("Test Case:07");
I7 = uint8([10 20 30 40 50;
            15 25 35 45 55;
            20 30 40 50 60;
            25 35 45 55 65;
            30 40 50 60 70]);

S7 = stdfilt(I7, ones(3, 5));
disp(S);


disp("Test Case:08");
I8 = double([1 2 3; 4 5 6; 7 8 9]);
S_rep = stdfilt(I8, ones(3,3), "replicate");
S_sym = stdfilt(I8, ones(3,3), "symmetric");
S_zer = stdfilt(I8, ones(3,3), "zeros");
disp(S_rep);
disp(" ");
disp(S_sym);
disp(" ");
disp(S_zer);


disp("Test Case:09");
H = [5.0 2.0 8.0; 1.0 -3.0 1.0; 5.0 1.0 0.0];
S = stdfilt(H, ones(3,3));
disp(S);


disp("Test Case:10");
I10 = zeros(7, 7);
I10(4, 4) = 100;
S10 = stdfilt(I10, ones(3,3));
disp(S10);