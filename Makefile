test:
	./node_modules/.bin/_mocha --compilers coffee:coffee-script/register --reporter spec

dev:
	coffee index.coffee

.PHONY: test
