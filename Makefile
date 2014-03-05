installable_epsilon: src/Epsilon/Compiler.pm src/Epsilon/Actions.pm src/Epsilon/Grammar.pm src/Epsilon/Runtime.pm src/pmc/void.pmc
	parrot setup.pir

test: installable_epsilon
	parrot setup.pir test
