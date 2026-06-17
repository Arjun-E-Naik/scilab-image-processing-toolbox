// test_bweuler.sce

exec("applylut.sci",-1);
exec("bweuler.sci",-1);

disp("========================================");
disp("TEST CASE 1 : Empty Image");


BW = zeros(5,5);
e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 2 : Single Pixel");


BW = zeros(5,5);
BW(3,3)=1;
e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 3 : Single Solid Object");


BW = ones(5,5);
e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 4 : Two Separate Objects");


BW = zeros(6,6);
BW(2,2)=1;
BW(5,5)=1;
e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 5 : Ring (One Hole)");


BW = [
1 1 1
1 0 1
1 1 1
];

e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 6 : Two Rings");


BW = [
1 1 1 0 1 1 1
1 0 1 0 1 0 1
1 1 1 0 1 1 1
];

e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 7 : Numeric Input");


BW = [
0 0 0
0 5 0
0 0 0
];

e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 8 : Connectivity Difference");


BW = [
1 0
0 1
];

e4 = bweuler(BW,4);
e8 = bweuler(BW,8);

disp(e4);
disp(e8);

disp("========================================");
disp("TEST CASE 9 : Large Ring");


BW = [
1 1 1 1 1
1 0 0 0 1
1 0 0 0 1
1 0 0 0 1
1 1 1 1 1
];

e = bweuler(BW);
disp(e);

disp("========================================");
disp("TEST CASE 10 : One Object Two Holes");


BW = [
1 1 1 1 1 1 1
1 0 1 1 1 0 1
1 1 1 1 1 1 1
];

e = bweuler(BW);
disp(e);

disp("========================================");