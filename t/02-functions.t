start = (x -> y -> print @ (x ~ ".." ~ y ~ "\n"));
start @ 1 @ 6;

foo = (-> print @ "ok 1\n"); foo!;

ok = (n -> print $ "ok " ~ n ~ "\n");
ok @ 2;
ok $ (x -> y -> y) @ 678 @ 3;

apply = (f -> x -> f @ x);
apply @ (x -> print $ "ok " ~ x ~ "\n") @ 4;

foo = (() -> print @ "ok 5\n"); foo!;

bar = x -> y -> z -> {
    ok $ x + y - z
};

bar @ 3 @ 4 @ 1;
