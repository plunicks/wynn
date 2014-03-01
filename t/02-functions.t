start = (x -> y -> print @ (x ~ ".." ~ y ~ "\n"));
start @ 1 @ 3;

foo = (-> print @ "ok 1\n"); foo!;

ok = (n -> print $ "ok " ~ n ~ "\n");
ok @ 2;
ok $ (x -> y -> y) @ 678 @ 3
