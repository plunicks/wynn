print "1..6\n";

ok = load 'Test';

x, y, z = 10, 20, 30;

ok $ x == 10;
ok $ y == 20;
ok $ z == 30;

a, b, c := "A", "B", "C";

ok $ a == "A";
ok $ b == "B";
ok $ c == "C";

()
