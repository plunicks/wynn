print "1..3\n";

ok = load 'Test';

ok $ :foo == "foo";
ok $ :foo ~ :bar == "foobar";
ok $ :foo ~ :bar == :foobar;

()
