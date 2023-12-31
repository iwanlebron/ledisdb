INSTALL_PATH ?= $(CURDIR)

#$(shell ./tools/build_config.sh build_config.mk $INSTALL_PATH)

#include build_config.mk

#export CGO_CFLAGS
#export CGO_CXXFLAGS
#export CGO_LDFLAGS
#export LD_LIBRARY_PATH
#export DYLD_LIBRARY_PATH
#export GO_BUILD_TAGS
#export GO111MODULE=on

#PACKAGES ?= $(shell GO111MODULE=on go list -mod=vendor ./... | grep -v /vendor/)
DIST := bin
#VERSION ?= $(shell git describe --tags --always | sed 's/-/+/' | sed 's/^v//')
LDFLAGS := $(LDFLAGS) -X "main.version=v1.0.0" -X "main.buildTags=$(GO_BUILD_TAGS)"

all: build

build: build-ledis

build-ledis:
	go build -o $(DIST)/ledis -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis/*.go

build-commands:
	go build -o $(DIST)/ledis-server -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-server/*.go
	go build -o $(DIST)/ledis-cli -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-cli/*.go
	go build -o $(DIST)/ledis-benchmark -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-benchmark/*.go
	go build -o $(DIST)/ledis-dump -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-dump/*.go
	go build -o $(DIST)/ledis-load -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-load/*.go
	go build -o $(DIST)/ledis-repair -tags '$(GO_BUILD_TAGS)' -ldflags '-s -w $(LDFLAGS)' cmd/ledis-repair/*.go

.PHONY: lint
lint:
	@hash golint > /dev/null 2>&1; if [ $$? -ne 0 ]; then \
		cd /tmp && GO111MODULE=on go get -u -v golang.org/x/lint/golint; \
	fi
	golint $(PACKAGES)

vet:
	go vet -tags '$(GO_BUILD_TAGS)' ./...

test:
	go test --race -tags '$(GO_BUILD_TAGS)' -cover -coverprofile coverage.out -timeout 10m $(PACKAGES)

clean:
	go clean -i $(PACKAGES)
