build:
	mkdir -p build/src/
	test -d source/ && git -C source/ pull || git clone git@github.com:clue-access/framework-x.git source/
	docker run --rm -i -v ${PWD}/source:/docs -u $(shell id -u) squidfunk/mkdocs-material build
	cp -r source/build/docs/ build/
	cp index.html build/
	cp src/* build/src/

serve: build
	php -S localhost:8080 -t build/

deploy:
	git -C build/ init
	git -C build/ checkout live 2>/dev/null || git -C build/ checkout -b live
	git -C build/ add --all
	git -C build/ diff-index HEAD >/dev/null 2>/dev/null || git -C build/ commit -m "Website build"
	git -C build/ remote get-url origin >/dev/null 2>/dev/null || git -C build/ remote add origin $(shell git remote get-url origin)
	git -C build/ push origin live -f

clean:
	rm -rf source/ build/

.PHONY: build serve deploy clean
