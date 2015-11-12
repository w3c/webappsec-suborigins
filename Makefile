all: clean index.html

clean:
	rm -rf ./index.html

index.html:
	bikeshed -f spec index.src.html

publish:
	git push origin master master:gh-pages
