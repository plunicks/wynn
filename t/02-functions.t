start = (x -> y -> print @ (x ~ ".." ~ y ~ "\n"));
start @ 1 @ 2;

foo = (-> print @ "ok 1\n"); foo!;

ok = (n -> print $ "ok " ~ n ~ "\n");
ok @ 2
