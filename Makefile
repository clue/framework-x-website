build:
	mkdir -p build/src/
	test -d source/ && git -C source/ pull || git clone git@github.com:clue-access/framework-x.git source/
	docker run --rm -i -v ${PWD}/source:/docs -u $(shell id -u) squidfunk/mkdocs-material build
	cp -r source/build/docs/ build/
	cp index.html build/
	cp src/* build/src/

serve: build
	php -S localhost:8080 -t build/

clean:
	rm -rf source/ build/

.PHONY: build serve clean
