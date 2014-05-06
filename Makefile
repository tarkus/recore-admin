build:
	./node_modules/.bin/coffee -c index.coffee

test:
	./node_modules/.bin/_mocha --compilers coffee:coffee-script/register --reporter spec

clean:
	rm -rf index.js

dev:
	coffee -wc --bare index.coffee

.PHONY: test
