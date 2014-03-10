class = {{ x ; y ; bar }};
f = class ();
f.x = 2;
f.y = 5;
print $ "1.." ~ (f.y - f.x + 8) ~ "\n";

(f.y - f.x == 3) && print "ok 1\n";

f.bar = {{ a ; b ; c }} ();
f.bar.a = "ok";
f.bar.b = 2;
f.bar.c = 3;

print $ (f.bar.a) ~ " " ~ f.bar.b ~ "\n";
print $ f.bar.a ~ " " ~ f.bar.c ~ "\n";

ok = {
    _test_count = 3; # start counting after the 3 tests above
    ok = expr -> {
        _test_count = _test_count + 1;
        expr || print "not ";
        print $ "ok " ~ _test_count ~ "\n"
    }
};


## Test that distinct objects are really distinct.

class1 = {{ x ; y ; bar }};

f10 = class1 (); f10.x = 10;
ok $ f10.x == 10;

class2 = {{ x ; y ; bar }};

f20 = class2 (); f20.x = 20;
ok $ f20.x == 20;

f21 = class2 (); f21.x = 21;
ok $ f21.x == 21;

class3 = {{ x ; y ; bar }};

f30 = class3 (); f30.x = 30;
ok $ f30.x == 30;

ok $ f10.x == 10;
ok $ f20.x == 20;
ok $ f21.x == 21;
ok $ f30.x == 30;

()
