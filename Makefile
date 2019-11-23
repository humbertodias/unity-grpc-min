#PLATFORM := macos_x64
PLATFORM := linux_x64

GRPC_CLIENT_DIR := client/csharp-unity/Assets/GRPC
GRPC_CLIENT_GENERATED_DIR := $(GRPC_CLIENT_DIR)/Pj.Grpc.Sample

GRPC_SERVER_GENERATED_DIR := server
GRPC_PROTOC_DIR := grpc-protoc

# https://packages.grpc.io/archive/2019/11/a30f2f95017bf0f53acf2a89056252eb3a2cbbab-b42eea7c-f904-45bf-aaef-5a1c7959c12c/index.xml

GRPC_BUILD_YEAR := 2019
GRPC_BUILD_MONTH := 11
GRPC_BUILD_COMMIT := a30f2f95017bf0f53acf2a89056252eb3a2cbbab-b42eea7c-f904-45bf-aaef-5a1c7959c12c
GRPC_BUILD_VERSION := 1.26.0-dev
GRPC_UNITY_VERSION := 2.26.0-dev

GRPC_PROTOC := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz
GRPC_PYTHON := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/python
GRPC_CSHARP_UNITY := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/csharp/grpc_unity_package.$(GRPC_UNITY_VERSION).zip
GRPC_PROTOC_PLUGINS := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz

GO_VERSION := 1.13.4
GO_PLATFORM := linux-amd64
GO_TAR_GZ := go$(GO_VERSION).$(GO_PLATFORM).tar.gz
GO_URL := https://dl.google.com/go/$(GO_TAR_GZ)


dep: grpc-protoc-plugins	grpc-unity-package

init-grpc-protoc-plugins:
	mkdir -p $(GRPC_PROTOC_DIR)

init-client:
	mkdir -p $(GRPC_CLIENT_GENERATED_DIR)

init-server:
	mkdir -p $(GRPC_SERVER_GENERATED_DIR)/go/pb

build-server:	protoc-server

build-client:	protoc-client

run-server-python:
	cd $(GRPC_SERVER_GENERATED_DIR)/python && python3 server.py

run-server-go:
	cd $(GRPC_SERVER_GENERATED_DIR)/go && go run server.go

run-server: run-server-python

run-client:
	@echo "TODO"

grpc-protoc-plugins:	init-grpc-protoc-plugins
	wget -O grpc-protoc.tar.gz $(GRPC_PROTOC_PLUGINS)
	tar xvfz grpc-protoc.tar.gz -C $(GRPC_PROTOC_DIR)
	chmod +x $(GRPC_PROTOC_DIR)/protoc
	rm grpc-protoc.tar.gz

grpc-unity-package:	init-client
	wget -O grpc_unity_package.zip $(GRPC_CSHARP_UNITY)
	unzip -o grpc_unity_package.zip -d $(GRPC_CLIENT_DIR)
	rm grpc_unity_package.zip

protoc-client:
	$(GRPC_PROTOC_DIR)/protoc -I proto --csharp_out $(GRPC_CLIENT_GENERATED_DIR) --grpc_out $(GRPC_CLIENT_GENERATED_DIR) proto/*.proto --plugin=protoc-gen-grpc=$(GRPC_PROTOC_DIR)/grpc_csharp_plugin

protoc-server-python:
	$(GRPC_PROTOC_DIR)/protoc -I proto --python_out $(GRPC_SERVER_GENERATED_DIR)/python --grpc_out $(GRPC_SERVER_GENERATED_DIR)/python proto/*.proto --plugin=protoc-gen-grpc=$(GRPC_PROTOC_DIR)/grpc_python_plugin

go-deps:
	go get -u github.com/golang/protobuf/proto
	go get -u github.com/golang/protobuf/protoc-gen-go 
	go get -u -v google.golang.org/grpc
	go get -u google.golang.org/grpc/codes
	go get -u google.golang.org/grpc/status

protoc-server-go:	init-server go-deps
	$(GRPC_PROTOC_DIR)/protoc -I proto --go_out=plugins=grpc:$(GRPC_SERVER_GENERATED_DIR)/go/pb proto/*.proto

protoc-server:	protoc-server-python

clean-client:
	rm -rf $(GRPC_CLIENT_DIR)

clean-server-python:
	rm -f $(GRPC_SERVER_GENERATED_DIR)/*_pb2*

clean-server-go:
	rm -rf $(GRPC_SERVER_GENERATED_DIR)/go/pb

clean-server: clean-server-python	clean-server-go

clean:	clean-client	clean-server
	rm -rf $(GRPC_PROTOC_DIR)

go-install:
	wget $(GO_URL)
	sudo tar -C /usr/local -xvzf $(GO_TAR_GZ)
	rm $(GO_TAR_GZ)