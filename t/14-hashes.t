print "1..6\n";

ok = load 'Test';

color =  :foo => "red"
      =| :bar => "blue"
      =| :baz => "green"
      =| :quz => "yellow"
;

ok $ (color :foo) == "red";
ok $ (color "foo") == (color :foo);
ok $ (color :quz) == "yellow";

color2 = (:foo => "red")
       | (:bar => "blue")
       | (:baz => "green")
       | (:quz => "yellow")
;

ok $ (color2 :foo) == "red";
ok $ (color2 "foo") == (color2 :foo);
ok $ (color2 :quz) == "yellow";

()
