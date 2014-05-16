test:
	./node_modules/.bin/_mocha --compilers coffee:coffee-script/register --reporter spec

dev:
	./node_modules/.bin/coffee index.coffee

.PHONY: test
