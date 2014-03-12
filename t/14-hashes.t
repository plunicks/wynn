print "1..3\n";

ok = load 'Test';

color =  :foo => "red"
      =| :bar => "blue"
      =| :baz => "green"
      =| :quz => "yellow"
;

ok $ (color :foo) == "red";
ok $ (color "foo") == (color :foo);
ok $ (color :quz) == "yellow";

()
