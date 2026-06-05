exec("entropy.sci",-1);
disp("Test cases for entropy function");

disp("Test case:01");
E = entropy([0, 1]);
disp(E);

disp("Test case:02");
E = entropy([0, 0]);
disp(E);


disp("Test case:03");
E = entropy([1]);
disp(E);

disp("Test case:04");
L = [%f %t %t; %f %t %t; %f %f %t] ;  // 5 false, 4 true
E = entropy(L);
disp(E);

disp("Test case:05");
U = 128 .* ones(3, 3);
E = entropy(U);
disp(E);

disp("Test case:06");
C = [1 1 1; 2 2 2; 3 3 3];
E = entropy(C);
disp(E);

