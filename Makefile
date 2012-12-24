coffeeDir = ./node_modules/coffee-script/bin/coffee

test:
	$(coffeeDir) -o ./test/js/ ./test/spec/
	$(coffeeDir) -o ./lib/ ./src/
	grunt test

.PHONY: test
