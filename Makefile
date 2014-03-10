installable_wynn: wynn.pir src/wynn.pir src/Wynn/Compiler.pm src/Wynn/Actions.pm src/Wynn/Grammar.pm src/Wynn/Runtime.pm src/pmc/void.pmc
	parrot setup.pir

test: installable_wynn
	parrot setup.pir test

clean:
	parrot setup.pir clean
