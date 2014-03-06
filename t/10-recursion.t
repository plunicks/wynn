/*
 * Build a whole test result string, including the plan line, recursively. In
 * order to allow this function to recurse, we first define the variable tests
 * in the current lexical scope, so that it's in scope when the function is
 * actually created. Then we create and assign the function.
 */
tests;
tests = cur -> max -> cur == 0
  && ("1.." ~ max ~ "\n")
  || (tests (cur - 1) max) ~ "ok " ~ cur ~ "\n";

print $ tests 10 10;

1
