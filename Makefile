all: clean index.html

clean:
	rm -rf ./index.html

index.html: index.bs
	curl https://www.w3.org/publications/spec-generator/ -F file=@index.bs -F type=bikeshed-spec -F die-on=nothing > ./index.html

local:
	bikeshed -f spec index.bs

publish:
	git push origin master master:gh-pages
