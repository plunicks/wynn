ok = load 'Test';

print "1..1\n";

f = ();
f = x -> y -> {
    sum = x + y;

    # This test will not work if the sum is 0.
    (y == "") && x || f (x + y)
};

sum = f 1 2 3 4 5 ();
ok $ sum == 15;

()
