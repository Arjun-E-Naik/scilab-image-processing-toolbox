// =============================================================================
// test_bwmorph.sci 
//
// Run with:
//   exec("bwmorph.sci")
//   exec("test_bwmorph.sci")
//

// =============================================================================
exec("bwmorph.sci",-1);
tests_run    = 0;
tests_passed = 0;

disp("========================================");
disp("Running bwmorph test suite (Scilab)");
disp("========================================");

// ============================================================
// TEST 1: clean
// ============================================================
disp(" "); disp("TEST 1: clean");

in1a  = ([0 0 0; 1 0 1; 0 0 1] ~= 0);
exp1a = ([0 0 0; 0 0 1; 0 0 1] ~= 0);
got1a = bwmorph(in1a, "clean");
tests_run = tests_run + 1;
if isequal(got1a, exp1a) then
    disp("  PASS: lone pixel removed, neighboured pixel kept");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: clean case A");
    disp("  Got:");      disp(double(got1a));
    disp("  Expected:"); disp(double(exp1a));
end

in1b  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
exp1b = (zeros(3,3) ~= 0);
got1b = bwmorph(in1b, "clean");
tests_run = tests_run + 1;
if isequal(got1b, exp1b) then
    disp("  PASS: single isolated pixel cleaned to zero");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: clean case B");
    disp("  Got:"); disp(double(got1b));
end

// ============================================================
// TEST 2: bridge
// ============================================================
disp(" "); disp("TEST 2: bridge");

in2  = ([1 0 0; 1 0 1; 0 0 1] ~= 0);
exp2 = ([1 1 0; 1 1 1; 0 1 1] ~= 0);
got2 = bwmorph(in2, "bridge");
tests_run = tests_run + 1;
if isequal(got2, exp2) then
    disp("  PASS: bridge connects diagonal regions");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: bridge");
    disp("  Got:");      disp(double(got2));
    disp("  Expected:"); disp(double(exp2));
end

// ============================================================
// TEST 3: dilate
// ============================================================
disp(" "); disp("TEST 3: dilate");

in3a  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
exp3a = (ones(3,3) ~= 0);
got3a = bwmorph(in3a, "dilate");
tests_run = tests_run + 1;
if isequal(got3a, exp3a) then
    disp("  PASS: single pixel dilates to fill 3x3");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: dilate single pixel");
    disp("  Got:"); disp(double(got3a));
end

in3b = ([1 1 0 0 1 0 1 0 0 0 1 1 1 0 1 1 0 1 0 0; ...
         1 1 1 0 1 0 1 1 1 1 0 1 0 1 0 0 0 0 0 0; ...
         0 1 1 1 0 1 1 0 0 0 1 1 0 0 1 1 0 0 1 0; ...
         0 0 0 0 0 1 1 1 1 0 0 1 1 1 1 1 1 0 0 1; ...
         0 1 0 0 1 1 0 1 1 0 0 0 0 0 1 1 0 0 1 0] ~= 0);
got3b_n3 = bwmorph(in3b, "dilate", 3);
tmp = bwmorph(in3b, "dilate");
tmp = bwmorph(tmp,  "dilate");
tmp = bwmorph(tmp,  "dilate");
tests_run = tests_run + 1;
if isequal(got3b_n3, tmp) then
    disp("  PASS: dilate(n=3) equals three sequential dilations");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: dilate n=3 vs sequential");
end

// ============================================================
// TEST 4: erode
// ============================================================
disp(" "); disp("TEST 4: erode");

in4a  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
exp4a = (zeros(3,3) ~= 0);
got4a = bwmorph(in4a, "erode");
tests_run = tests_run + 1;
if isequal(got4a, exp4a) then
    disp("  PASS: single pixel vanishes under erosion");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: erode single pixel");
    disp("  Got:"); disp(double(got4a));
end

in4b  = (ones(3,3) ~= 0);
exp4b = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
got4b = bwmorph(in4b, "erode");
tests_run = tests_run + 1;
if isequal(got4b, exp4b) then
    disp("  PASS: 3x3 block erodes to single center pixel");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: erode 3x3 block");
    disp("  Got:");      disp(double(got4b));
    disp("  Expected:"); disp(double(exp4b));
end

// ============================================================
// TEST 5: remove
// ============================================================
disp(" "); disp("TEST 5: remove");

in5 = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
exp5 = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 0 1 1; 1 1 1 1 1] ~= 0);
got5 = bwmorph(in5, "remove");
tests_run = tests_run + 1;
if isequal(got5, exp5) then
    disp("  PASS: remove hollows out interior pixels");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: remove");
    disp("  Got:");      disp(double(got5));
    disp("  Expected:"); disp(double(exp5));
end

got5inf = bwmorph(in5, "remove", %inf);
tests_run = tests_run + 1;
if isequal(got5inf, exp5) then
    disp("  PASS: remove(n=Inf) gives same result as remove(n=1)");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: remove n=Inf");
    disp("  Got:"); disp(double(got5inf));
end

// ============================================================
// TEST 6: fill
// ============================================================
disp(" "); disp("TEST 6: fill");

in6  = ([0 1 0 1 0; 1 1 1 0 1; 1 0 0 1 0; 1 1 1 0 1; 1 1 1 1 1] ~= 0);
exp6 = ([0 1 0 1 0; 1 1 1 1 1; 1 0 0 1 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
got6 = bwmorph(in6, "fill");
tests_run = tests_run + 1;
if isequal(got6, exp6) then
    disp("  PASS: fill correctly fills enclosed holes");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: fill");
    disp("  Got:");      disp(double(got6));
    disp("  Expected:"); disp(double(exp6));
end

// ============================================================
// TEST 7: hbreak
// ============================================================
disp(" "); disp("TEST 7: hbreak");

in7  = ([1 1 1; 0 1 0; 1 1 1] ~= 0);
exp7 = ([1 1 1; 0 0 0; 1 1 1] ~= 0);
got7 = bwmorph(in7, "hbreak");
tests_run = tests_run + 1;
if isequal(got7, exp7) then
    disp("  PASS: hbreak removes H-junction center pixel");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: hbreak");
    disp("  Got:");      disp(double(got7));
    disp("  Expected:"); disp(double(exp7));
end

// ============================================================
// TEST 8: diag
// ============================================================
disp(" "); disp("TEST 8: diag");

in8  = ([0 1 0; 1 0 0; 0 0 0] ~= 0);
exp8 = ([1 1 0; 1 1 0; 0 0 0] ~= 0);
got8 = bwmorph(in8, "diag");
tests_run = tests_run + 1;
if isequal(got8, exp8) then
    disp("  PASS: diag fills the diagonal gap");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: diag");
    disp("  Got:");      disp(double(got8));
    disp("  Expected:"); disp(double(exp8));
end

// ============================================================
// TEST 9: endpoints
// ============================================================
disp(" "); disp("TEST 9: endpoints");

in9a  = ([1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 0] ~= 0);
exp9a = ([1 0 0 0; 0 0 0 0; 0 0 1 0; 0 0 0 0] ~= 0);
got9a = bwmorph(in9a, "endpoints");
tests_run = tests_run + 1;
if isequal(got9a, exp9a) then
    disp("  PASS: endpoints finds both tips of a diagonal line");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: endpoints diagonal");
    disp("  Got:");      disp(double(got9a));
    disp("  Expected:"); disp(double(exp9a));
end

in9b  = ([0 0 0 0 0; 0 0 1 0 0; 0 1 1 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
exp9b = ([0 0 0 0 0; 0 0 1 0 0; 0 1 0 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
got9b = bwmorph(in9b, "endpoints");
tests_run = tests_run + 1;
if isequal(got9b, exp9b) then
    disp("  PASS: endpoints finds the four tips of a cross");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: endpoints cross");
    disp("  Got:");      disp(double(got9b));
    disp("  Expected:"); disp(double(exp9b));
end

in9c = ([0 0 0 0 0 0 0 0; 1 1 0 0 0 0 1 1; 0 0 1 1 1 1 0 0; ...
         0 0 0 1 1 0 0 0; 0 0 1 1 1 1 0 0; 0 1 0 0 0 0 1 0; ...
         1 0 0 0 0 0 0 1] ~= 0);
exp9c = ([0 0 0 0 0 0 0 0; 1 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0; ...
          0 0 0 1 1 0 0 0; 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0; ...
          1 0 0 0 0 0 0 1] ~= 0);
got9c = bwmorph(in9c, "endpoints");
tests_run = tests_run + 1;
if isequal(got9c, exp9c) then
    disp("  PASS: endpoints on figure-8 shape");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: endpoints figure-8");
    disp("  Got:");      disp(double(got9c));
    disp("  Expected:"); disp(double(exp9c));
end

// ============================================================
// TEST 10: open and close
// ============================================================
disp(" "); disp("TEST 10: open and close");

all1 = (ones(5,5)  ~= 0);
all0 = (zeros(5,5) ~= 0);

tests_run = tests_run + 1;
if isequal(bwmorph(all1, "open"), all1) then
    disp("  PASS: open(all-ones) = all-ones");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: open(all-ones) changed");
end

tests_run = tests_run + 1;
if isequal(bwmorph(all1, "close"), all1) then
    disp("  PASS: close(all-ones) = all-ones");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: close(all-ones) changed");
end

tests_run = tests_run + 1;
if isequal(bwmorph(all0, "open"), all0) then
    disp("  PASS: open(all-zeros) = all-zeros");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: open(all-zeros) changed");
end

tests_run = tests_run + 1;
if isequal(bwmorph(all0, "close"), all0) then
    disp("  PASS: close(all-zeros) = all-zeros");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: close(all-zeros) changed");
end

// open = erode-then-dilate, close = dilate-then-erode on a real image
in10 = ([1 1 0 0 1 0 1 0 0 0 1 1 1 0 1 1 0 1 0 0; ...
         1 1 1 0 1 0 1 1 1 1 0 1 0 1 0 0 0 0 0 0; ...
         0 1 1 1 0 1 1 0 0 0 1 1 0 0 1 1 0 0 1 0; ...
         0 0 0 0 0 1 1 1 1 0 0 1 1 1 1 1 1 0 0 1; ...
         0 1 0 0 1 1 0 1 1 0 0 0 0 0 1 1 0 0 1 0] ~= 0);
eroded10  = conv2(double(in10), ones(3,3), "same") >= 9;
opened10  = conv2(double(eroded10), ones(3,3), "same") > 0;
dilated10 = conv2(double(in10), ones(3,3), "same") > 0;
closed10  = conv2(double(dilated10), ones(3,3), "same") >= 9;
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "open"), opened10) then
    disp("  PASS: open matches erode-then-dilate on 5x20 image");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: open on 5x20 image");
end
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "close"), closed10) then
    disp("  PASS: close matches dilate-then-erode on 5x20 image");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: close on 5x20 image");
end

// ============================================================
// TEST 11: tophat and bothat
// ============================================================
disp(" "); disp("TEST 11: tophat and bothat");

tests_run = tests_run + 1;
if isequal(bwmorph(all1, "tophat"), all0) then
    disp("  PASS: tophat(all-ones) = all-zeros");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: tophat(all-ones)");
    disp("  Got:"); disp(double(bwmorph(all1, "tophat")));
end

tests_run = tests_run + 1;
if isequal(bwmorph(all0, "bothat"), all0) then
    disp("  PASS: bothat(all-zeros) = all-zeros");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: bothat(all-zeros)");
end

exp_tophat = in10 & ~opened10;
exp_bothat = closed10 & ~in10;
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "tophat"), exp_tophat) then
    disp("  PASS: tophat matches manual computation");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: tophat on 5x20 image");
end
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "bothat"), exp_bothat) then
    disp("  PASS: bothat matches manual computation");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: bothat on 5x20 image");
end

// ============================================================
// TEST 12: majority
// ============================================================
disp(" "); disp("TEST 12: majority");

tests_run = tests_run + 1;
if isequal(bwmorph(all1, "majority"), all1) then
    disp("  PASS: majority(all-ones) = all-ones");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: majority(all-ones)");
end

tests_run = tests_run + 1;
if isequal(bwmorph(all0, "majority"), all0) then
    disp("  PASS: majority(all-zeros) = all-zeros");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: majority(all-zeros)");
end



// ============================================================
// TEST 13: skel-lantuejoul  (Gonzalez & Woods fig 8.39)
// ============================================================
disp(" "); disp("TEST 14: skel-lantuejoul");

slBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
         0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; ...
         0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 0 0 0 0] ~= 0);

rslBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
          0 0 0 0 0 0 0; 0 0 0 1 0 0 0; 0 0 0 1 0 0 0; 0 0 0 0 0 0 0; ...
          0 0 0 1 0 0 0; 0 0 0 0 0 0 0; 0 0 0 0 0 0 0; 0 0 0 0 0 0 0] ~= 0);

exp_n1 = ([rslBW(1:5,:); zeros(7,7)] ~= 0);
got_n1 = bwmorph(slBW, "skel-lantuejoul", 1);
tests_run = tests_run + 1;
if isequal(got_n1, exp_n1) then
    disp("  PASS: skel-lantuejoul n=1 correct");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: skel-lantuejoul n=1");
    disp("  Got:");      disp(double(got_n1));
    disp("  Expected:"); disp(double(exp_n1));
end

got_n3  = bwmorph(slBW, "skel-lantuejoul", 3);
got_inf = bwmorph(slBW, "skel-lantuejoul", %inf);
tests_run = tests_run + 1;
if isequal(got_n3, rslBW) then
    disp("  PASS: skel-lantuejoul n=3 gives correct skeleton");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: skel-lantuejoul n=3");
    disp("  Got:");      disp(double(got_n3));
    disp("  Expected:"); disp(double(rslBW));
end
tests_run = tests_run + 1;
if isequal(got_inf, rslBW) then
    disp("  PASS: skel-lantuejoul n=Inf gives correct skeleton");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: skel-lantuejoul n=Inf");
    disp("  Got:"); disp(double(got_inf));
end

// ============================================================
// TEST 14: skel  (Octave bug #39293 test)
// ============================================================
disp(" "); disp("TEST 15: skel");

bw_skel = ([0 1 1 1 1 1; 0 1 1 1 1 1; 0 1 1 1 1 1; ...
            1 1 1 1 1 1; 1 1 1 1 1 1; 1 1 1 1 1 1; ...
            1 1 1 1 1 0; 1 1 1 1 1 0; 1 1 1 1 1 0] ~= 0);
exp_skel = ([0 1 0 0 0 1; 0 0 1 0 1 0; 0 0 0 1 0 0; ...
             0 0 0 1 0 0; 0 0 1 1 0 0; 0 0 1 0 0 0; ...
             0 0 1 0 0 0; 0 1 0 1 0 0; 1 0 0 0 1 0] ~= 0);
got_skel_inf = bwmorph(bw_skel, "skel", %inf);
got_skel_3   = bwmorph(bw_skel, "skel", 3);
tests_run = tests_run + 1;
if isequal(got_skel_inf, exp_skel) then
    disp("  PASS: skel(n=Inf) produces correct skeleton");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: skel n=Inf");
    disp("  Got:");      disp(double(got_skel_inf));
    disp("  Expected:"); disp(double(exp_skel));
end
tests_run = tests_run + 1;
if isequal(got_skel_3, exp_skel) then
    disp("  PASS: skel(n=3) matches skel(n=Inf)");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: skel n=3");
    disp("  Got:"); disp(double(got_skel_3));
end

// ============================================================
// TEST 15: dilate/erode consistency check
// ============================================================
disp(" "); disp("TEST 16: dilate/erode internal consistency");

ref_dil = conv2(double(in10), ones(3,3), "same") > 0;
ref_ero = conv2(double(in10), ones(3,3), "same") >= 9;
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "dilate"), ref_dil) then
    disp("  PASS: bwmorph dilate matches conv2 reference");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: bwmorph dilate vs conv2 reference");
end
tests_run = tests_run + 1;
if isequal(bwmorph(in10, "erode"), ref_ero) then
    disp("  PASS: bwmorph erode matches conv2 reference");
    tests_passed = tests_passed + 1;
else
    disp("  FAIL: bwmorph erode vs conv2 reference");
end

// ============================================================
// SUMMARY
// ============================================================
disp(" ");
disp("========================================");
disp("SUMMARY");
printf("Passed: %d / %d\n", tests_passed, tests_run);
if tests_passed == tests_run then
    disp("All tests passed!");
else
    printf("%d test(s) FAILED - see details above\n", tests_run - tests_passed);
end
disp("========================================");
