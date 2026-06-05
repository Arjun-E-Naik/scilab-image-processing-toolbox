exec("bwmorph.sci",-1);

disp("test cases for bwmorph function");

disp("Test for clean function");
in  = ([0 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "clean");
disp(double(out));
// pixel at (2,1) has no white neighbours → removed
// pixel at (2,3) touches (3,3) → kept
// Expected:
// 0  0  0
// 0  0  1
// 0  0  1

disp("test for bridge function");
in  = ([1 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "bridge");
disp(double(out));
// The gap pixel at (1,2) and (2,2) bridge the two disconnected regions
// Expected:
// 1  1  0
// 1  1  1
// 0  1  1

disp("test for dialate function");
in  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
out = bwmorph(in, "dilate");
disp(double(out));
// Every pixel within the 3x3 window of the center becomes 1
// Expected: ones(3,3)

disp("test for erode function");
in  = ones(3,3) ~= 0;
out = bwmorph(in, "erode");
disp(double(out));
// Only the center pixel has all 9 neighbours as 1
// Expected:
// 0  0  0
// 0  1  0
// 0  0  0

disp("test for remove function");
in  = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
out = bwmorph(in, "remove");
disp(double(out));
// Position (4,3): all 4 direct neighbours are 1 → removed
// Expected:
// 0  1  0  0  0
// 1  0  0  1  0
// 1  0  1  0  0
// 1  1  0  1  1
// 1  1  1  1  1


disp("test for endpoints function");
in  = ([0 0 0 0 0; 0 0 1 0 0; 0 1 1 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
out = bwmorph(in, "endpoints");
disp(double(out));
// The center pixel has 4 neighbours → not an endpoint
// Each arm tip has 1 neighbour → endpoint
// Expected:
// 0  0  0  0  0
// 0  0  1  0  0
// 0  1  0  1  0
// 0  0  1  0  0
// 0  0  0  0  0


// 12x7 irregular blob from Gonzalez & Woods fig 8.39
slBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
         0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; ...
         0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 0 0 0 0] ~= 0);

out_n1  = bwmorph(slBW, "skel-lantuejoul", 1);    // first level only
out_n3  = bwmorph(slBW, "skel-lantuejoul", 3);    // three levels
out_inf = bwmorph(slBW, "skel-lantuejoul", %inf); // full skeleton
disp("test for out_n1 function");
disp(double(out_n1));

disp("test for out_n3 function");
disp(double(out_n3));

disp("test for out_inf function");
disp(double(out_inf));
