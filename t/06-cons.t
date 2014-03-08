print @ "1..4\n";

print @ "ok ";
print $ "test" >> (); # prints the number of elements (1)
print @ "\n";

print @ "ok ";
print $ (("1234" >> ())[0][1]); # prints the '2' from the first element
print @ "\n";

print @ "ok ";
print $ (100 >> 200 >> 300 >> ()); # prints the number of elements
print @ "\n";

print @ "ok ";
print $ ((100 >> 200 >> 300 >> ())[2]) / 3 - 96;
print @ "\n"
