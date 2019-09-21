build:
	go build .

linux:
	GOOS=linux go build .

archive: linux
	tar zcvf belt-demo.tar.gz belt-demo-app belt-demo.service Caddyfile .env

.PHONY: build linux archive
