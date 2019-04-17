#PLATFORM := macos_x64
PLATFORM := linux_x64

GRPC_CLIENT_DIR := client/csharp-unity/Assets/GRPC
GRPC_CLIENT_GENERATED_DIR := $(GRPC_CLIENT_DIR)/Pj.Grpc.Sample

GRPC_SERVER_GENERATED_DIR := server
GRPC_PROTOC_DIR := grpc-protoc

# https://packages.grpc.io/archive/2019/04/8054a731d1486e439e6becb1987b1e97246e6476-c278eb13-0168-45da-b041-875459bcbc41/index.xml

GRPC_BUILD_YEAR := 2019
GRPC_BUILD_MONTH := 04
GRPC_BUILD_COMMIT := 8054a731d1486e439e6becb1987b1e97246e6476-c278eb13-0168-45da-b041-875459bcbc41
GRPC_BUILD_VERSION := 1.21.0-dev

GRPC_PROTOC := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz
GRPC_PYTHON := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/python
GRPC_CSHARP_UNITY := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/csharp/grpc_unity_package.$(GRPC_BUILD_VERSION).zip
GRPC_PROTOC_PLUGINS := https://packages.grpc.io/archive/$(GRPC_BUILD_YEAR)/$(GRPC_BUILD_MONTH)/$(GRPC_BUILD_COMMIT)/protoc/grpc-protoc_$(PLATFORM)-$(GRPC_BUILD_VERSION).tar.gz

GO_VERSION := 1.12.4
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
	cd $(GRPC_SERVER_GENERATED_DIR)/python && python server.py

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

protoc-server-go:	init-server
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