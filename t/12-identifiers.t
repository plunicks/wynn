print "1..15\n";

ok = load 'Test';

identifier-with-hyphen = 2;
ok identifier-with-hyphen;
another-identifier = 0;
ok $ ¬another-identifier;

x' = 10;
ok $ x' == 10;
a'b'''c = 2;
ok $ a'b'''c == identifier-with-hyphen;

x = 156;
ok $ x == 156;
ok $ «x» == 156;
ok $ x == «x»;

# quoted variable names
«^%F@18!(*sLSh3hf#EHFfĸóøäðá³³ĸéł⁅⁆» = "test string";
ok $ «^%F@18!(*sLSh3hf#EHFfĸóøäðá³³ĸéł⁅⁆» == "test string";
foo = «^%F@18!(*sLSh3hf#EHFfĸóøäðá³³ĸéł⁅⁆» ~ " " ~ «x»;
ok $ foo == "test string 156";

# quoted operators called as functions
ok $ «<» 1 2;
ok $ («+» 8 7) == 15;
ok $ («,» 247) 0 == 247;
ok $ («+» 8 $ «*» 2 7) == 22;
ok $ «!=» 19 71;
ok $ «==» («-» 100 43) $ «+» 50 $ «/» 14 2;

()
