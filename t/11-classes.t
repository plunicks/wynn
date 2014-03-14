class := [ x ; y ; bar ];
f = class ();
f.x = 2;
f.y = 5;
print $ "1.." ~ (f.y - f.x + 11) ~ "\n";

ok = load 'Test';

ok (f.y - f.x == 3);

f.bar = [ a ; b ; c ] ();
f.bar.a = "ok";
f.bar.b = 2;
f.bar.c = 3;

ok $ f.bar.b == 2;
ok $ f.bar.c == 3;


## Test that distinct objects are really distinct.

class1 := [ x ; y ; bar ];

f10 = class1 (); f10.x = 10;
ok $ f10.x == 10;

class2 := [ x ; y ; bar ];

f20 = class2 (); f20.x = 20;
ok $ f20.x == 20;

f21 = class2 (); f21.x = 21;
ok $ f21.x == 21;

class3 := [ x ; y ; bar ];

f30 = class3 (); f30.x = 30;
ok $ f30.x == 30;

ok $ f10.x == 10;
ok $ f20.x == 20;
ok $ f21.x == 21;
ok $ f30.x == 30;

Cow := [
    name;
    hoofs = 4;
    moo = (self, x -> "moo, \{x}!")
];

cow = Cow ();
cow.name = "Jane";

ok $ (callmethod cow "moo" "foo") == "moo, foo!";
ok $ cow.hoofs == 4;
ok $ "The cow \{cow.name} has \{cow.hoofs} hoofs."
     == "The cow Jane has 4 hoofs."
()
