all: clean index.html

clean:
	rm -rf ./index.html

index.html:
	bikeshed -f spec index.bs

publish:
	git push origin master master:gh-pages
