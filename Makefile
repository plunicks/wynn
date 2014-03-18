installable_wynn: wynn.pir src/wynn.pir src/Wynn/*.pm src/pmc/void.pmc src/classes/*.pir
	parrot setup.pir

test: installable_wynn
	parrot setup.pir test

clean:
	parrot setup.pir clean
