all: clean index.html

clean:
	rm -rf ./index.html

index.html: index.bs
	curl https://api.csswg.org/bikeshed/ -F file=@index.bs -F force=1 > ./index.html

publish:
	git push origin master master:gh-pages
