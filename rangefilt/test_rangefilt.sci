exec("rangefilt.sci",-1);


disp("Test Case :01");
I = uint8(50 * ones(4, 4));
R = rangefilt(I);
disp(R);

disp("Test Case :02");
I = [zeros(4,2), ones(4,2)];
R = rangefilt(I);
disp(R);

disp("Test Case :03");
I      = [1 2; 3 4];
domain = ones(2, 2);
R      = rangefilt(I, domain);
disp(R);

disp("Test Case :04");
I      = [1  2  3;
          4  5  6;
          7  8  9];
domain = [0 1 0;
          1 1 1;
          0 1 0];
R      = rangefilt(I, domain);
disp(R);


disp("Test Case :05");
I = [42];
R = rangefilt(I);
disp(R);


disp("Test Case :06");
I = [%t %f %t; %f %t %f; %t %f %t];
R = rangefilt(I);
disp(R);


disp("Test Case :07");
I   = double([10 20 30; 40 50 60; 70 80 90]);
ref = zeros(3, 3);
R   = rangefilt(I);
disp(R);
