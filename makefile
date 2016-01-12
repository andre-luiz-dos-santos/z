
install:
	fish install.fish

test:
	fish test.fish 2>&1 | diff test.expected.output -
run:
	fish test.fish 2>&1 | tee test.expected.output
