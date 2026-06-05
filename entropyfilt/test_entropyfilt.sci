exec("entropyfilt.sci",-1);
disp("Test cases for entropyfilt function");
disp("Test case:01");
A = ones(10, 10);
E = entropyfilt(A);
disp(E);

disp("Test case:02");
A = zeros(3, 3);
E = entropyfilt(A);
disp(E);

disp("Test case:03");
M = uint8([17 24  1  8 15;
           23  5  7 14 16;
            4  6 13 20 22;
           10 12 19 21  3;
           11 18 25  2  9]);

E = entropyfilt(M, ones(3,3));
disp(E);


disp("Test case:04");
R = uint8([ 1  2  3  4  5;
           11 12 13 14 15;
           21 22  4  5  6;
            5  5  3  2  1;
           15 14 14 14 14]);

E = entropyfilt(R, ones(3,3));
disp(E);

disp("Test case:05");
H = [5 2 8; 1 -3 1; 5 1 0];
E = entropyfilt(H, ones(3,3));
disp(E);

disp("Test case:06");
Q = uint16([100 101 103; 100 105 102; 100 102 103]);
E = entropyfilt(Q, ones(3,3));
disp(E);

disp("Test case:07");
I7 = uint8([10 20 30 40 50;
            15 25 35 45 55;
            20 30 40 50 60;
            25 35 45 55 65;
            30 40 50 60 70]);

E = entropyfilt(I7, ones(3, 5));
disp(E);

disp("Test case:08");
I8 = double([1 2 3; 4 5 6; 7 8 9]) / 9;
E_sym = entropyfilt(I8, ones(3,3), "symmetric");
E_rep = entropyfilt(I8, ones(3,3), "replicate");
disp(E_sym);

disp(E_rep);
