print "1..10\n";
ok = (n -> print $ "ok " ~ n ~ "\n");

ok $ 1 + ();
ok $ () + 2;
ok $ 3 * ();
ok $ () * 4;
ok $ 5 - ();
ok $ -(() - 6);
ok $ 7 / ();
ok $ () / 7 + 8;
ok $ "9" ~ ();
ok $ () ~ "10"

