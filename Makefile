coffeeDir = ./node_modules/coffee-script/bin/coffee

test:
	$(coffeeDir) -o ./test/js/ ./test/spec/
	$(coffeeDir) -o ./lib/ ./src/
	@echo "Compiled tests, you can now open test/tests.html and run them"

.PHONY: test
