test:
	./node_modules/.bin/_mocha --compilers coffee:coffee-script/register --reporter spec

dev:
	nodemon -e ".coffee, .js" index.coffee

.PHONY: test
