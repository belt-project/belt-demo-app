build:
	GOOS=linux go build .

archive: build
	tar zcvf belt-demo.tar.gz belt-demo-app belt-demo.service Caddyfile .env

.PHONY: build archive
