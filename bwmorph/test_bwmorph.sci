
// TEST CASE 1
// Single isolated pixel
// should remain unchanged
exec("bwmorph.sci",-1);

bw = [
0 0 0 0 0;
0 0 0 0 0;
0 0 1 0 0;
0 0 0 0 0;
0 0 0 0 0
];

disp("TEST1");
disp(bwmorph_thin_fast(bw));




// TEST CASE 2
// Horizontal line
// already one-pixel thick
// no change


bw = [
0 0 0 0 0;
0 0 0 0 0;
1 1 1 1 1;
0 0 0 0 0;
0 0 0 0 0
];

disp("TEST2");
disp(bwmorph_thin_fast(bw));




// TEST CASE 3
// Vertical thick line
// reduced toward center line


bw = [
0 1 1 1 0;
0 1 1 1 0;
0 1 1 1 0;
0 1 1 1 0;
0 1 1 1 0
];

disp("TEST3");
disp(bwmorph_thin_fast(bw));




// TEST CASE 4
// Filled square
// skeleton-like center structure


bw = [
0 0 0 0 0 0 0;
0 1 1 1 1 1 0;
0 1 1 1 1 1 0;
0 1 1 1 1 1 0;
0 1 1 1 1 1 0;
0 1 1 1 1 1 0;
0 0 0 0 0 0 0
];

disp("TEST4");
disp(bwmorph_thin_fast(bw));




// TEST CASE 5
// Cross shape
// preserve topology


bw = [
0 0 1 0 0;
0 0 1 0 0;
1 1 1 1 1;
0 0 1 0 0;
0 0 1 0 0
];

disp("TEST5");
disp(bwmorph_thin_fast(bw));




// TEST CASE 6
// Hollow box
// should largely remain unchanged
// already thin boundary


bw = [
1 1 1 1 1;
1 0 0 0 1;
1 0 0 0 1;
1 0 0 0 1;
1 1 1 1 1
];

disp("TEST6");
disp(bwmorph_thin_fast(bw));




// TEST CASE 7
// Letter T
// preserve T structure


bw = [
1 1 1 1 1;
0 0 1 0 0;
0 0 1 0 0;
0 0 1 0 0;
0 0 1 0 0
];

disp("TEST7");
disp(bwmorph_thin_fast(bw));




// TEST CASE 8
// Noisy object
// skeleton + preserve connectivity


bw = [
0 0 1 0 0 0;
0 1 1 1 0 1;
1 1 1 1 1 0;
0 1 1 1 0 0;
0 0 1 0 0 1;
0 0 0 0 0 0
];

disp("TEST8");
disp(bwmorph_thin_fast(bw));