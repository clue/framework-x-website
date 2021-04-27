build:
	mkdir -p build/output/src/
	test -d build/source/ && git -C build/source/ pull || git clone git@github.com:clue-access/framework-x.git build/source/
	docker run --rm -i -v ${PWD}/build/source:/docs -u $(shell id -u) squidfunk/mkdocs-material build
	cp -r build/source/build/docs/ build/output/
	cp index.html build/output/
	cp src/* build/output/src/

serve: build
	php -S localhost:8080 -t build/output/

clean:
	rm -rf build/

.PHONY: build serve clean
