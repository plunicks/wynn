class = {{ x ; y ; bar }};
f = new class;
f.x = 2;
f.y = 5;
print $ "1.." ~ (f.y - f.x) ~ "\n";

(f.y - f.x == 3) && print "ok 1\n";

f.bar = new {{ a ; b ; c }};
f.bar.a = "ok";
f.bar.b = 2;
f.bar.c = 3;

print $ (f.bar.a) ~ " " ~ f.bar.b ~ "\n";
print $ f.bar.a ~ " " ~ f.bar.c ~ "\n";

()
