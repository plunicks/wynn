print $ "1..37\n";

ok = load 'Test';

# string concatenation
ok $ ("a" ~ "b" ~ "c" == "abc");

# strings are not equal to zero unless they are the string "0"
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

# string interpolation
ok ("foo\{}bar" == "foobar");

x = "bar";
ok ("foo\{x}" == "foobar");

ok ("foo\{"bar"}" == "foobar");

{ # string interpolation inside an interpolated expression
    f = c -> "ba" ~ c;
    ok ("foo\{(f "r") ~ "baz\{(f "t") ~ (f "k")}"}" == "foobarbazbatbak")
};

x = "ooba";
ok ("f\{x}r" == "foobar");

x = 3; y = 7;

ok ("foo\{x + y * 100}bar" == "foo703bar");

ok ("f\{(arg -> arg ~ arg ~ arg) @ "o"}bar" == "fooobar");

ok ("f\{(arg ->
    arg ~ arg ~ arg
) @ "o"}bar" == "fooobar");

ok ("f\{(arg1 -> arg2 -> (
    arg1 ~ arg1 ~ arg1 ~ arg2 * arg2
)) @ "o" @ 5}bar" == "fooo25bar");

ok $ "\{"foo" ~ {"abc";"def";"baz"}}bar" == "foobazbar";

x = 456;
ok $ "foo\{x = 123}" == "foo123";

ok $ "f\{{xyz = 123}}bar" == "f123bar";

ok $ "\{x = 1}";
ok $ ¬"\{x = 0}";
ok $ "\{x = 10; x + 5}" == 15;

ok $ "f\{xyz = 123}bar" == "f123bar";

ok ("f\{f = arg1 -> arg2 -> {
    arg1 ~ arg1 ~ arg1 ~ arg2 * arg2
}; f "o" 5}bar" == "fooo25bar");

# indexing a string (substring)
ok $ 'bar' 2 == 'r';
ok $ 'bar' (0, 1, 2) 2 == 'r';
ok $ "abcdefghi" 4 == "e";
ok $ "abcdefghi" (4, 5, 6, 7, 8) 4 == "i";

1
