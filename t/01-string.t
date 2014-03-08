print $ "1..16\n";

ok = {
    _test_count = 0;
    ok = expr -> {
        _test_count = _test_count + 1;
        expr || print "not ";
        print $ "ok " ~ _test_count ~ "\n"
    }
};

// string concatenation
ok $ ("a" ~ "b" ~ "c" == "abc");

// strings are not equal to zero unless they are the string "0"
ok $ ¬("foo" == 0);
ok $ ¬(0 == "foo");
ok $ "foo" != 0;
ok $ 0 != "foo";

ok $ "aaa" < "aab";
ok $ "aaa" < "aab";
ok $ "a" < "aa";
ok $ "b" > "aa";
ok $ "aab" > "aaa";

ok $ "bar" >= "bar";
ok $ "bar" >= "baq";
ok $ ¬("bar" >= "bas");

ok $ "bar" <= "bar";
ok $ "bar" <= "bas";
ok $ ¬("bar" <= "baq");

1
