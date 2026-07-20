.PHONY: test build demo observe down fmt check generate

test:
	go test ./...
	cd examples/hello-api && go test ./...

build:
	mkdir -p bin
	go build -trimpath -o bin/platformctl ./cmd/platformctl

fmt:
	gofmt -w cmd internal examples

check:
	go vet ./...
	cd examples/hello-api && go vet ./...

demo:
	docker compose up --build demo-api

observe:
	docker compose --profile observe up --build

down:
	docker compose --profile observe down

generate: build
	./bin/platformctl new service --name sample-api --owner platform-team --output ./sandbox
