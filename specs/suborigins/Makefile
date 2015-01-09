all: clean index.html

clean:
	rm -rf index.html

index.html: index.src.html
	bikeshed -q spec index.src.html index.html

publish: all
	git push origin master
	git push origin master:gh-pages
