print "1..6\n";

_test_count = 0;
ok = expr -> {
    _test_count = _test_count + 1;
    expr || print "not ";
    print $ "ok " ~ _test_count ~ "\n"
};

numbers = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
quadruple = x -> x * 4;
quadrupled = map quadruple numbers << 44 << 48;
gt3 = grep (_ -> _ > 3) (7 >> 10, 3, 2, 4, -1, 8, 12, -4, 18 << 2);
some = map (_ -> _ * 45)
           (grep (_ -> _ * 5 > 200)
                 quadrupled);

ok $ numbers 9 == 10;
ok $ quadrupled 9 == 40;
ok $ quadrupled 11 == 48; # added after map, so not modified
ok $ +gt3 == 6;
ok $ gt3 0 == 7;
ok $ some 1 == 2160;

1
