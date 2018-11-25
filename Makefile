PLATFORM := macosx_x64
#PLATFORM := linux-x86_64
#PLATFORM := linux-amd64
GRPC_TOOLS_VERSION := 1.18.0-dev
GO_VERSION := 1.11.2
PROTOC_VERSION := 3.6.1

GRPC_CLIENT_DIR := client/csharp-unity/Assets/GRPC
GRPC_CLIENT_GENERATED_DIR := $(GRPC_CLIENT_DIR)/Pj.Grpc.Sample

init-grpc-tools:
	mkdir -p Grpc.Tools

init-client:
	mkdir -p $(GRPC_CLIENT_GENERATED_DIR) $(GRPC_CLIENT_PLUGINS_DIR)

init:	init-client	init-grpc-tools

python-requirements:
	cd server/python && \
	pip install -r requirements.txt

build-server:	grpc-tools-python	protoc-server

build-client:	grpc-tools-csharp	grpc-unity-package	protoc-client

run-server:
	cd server/python && \
	python server.py

run-client:

grpc-tools-csharp:	init-grpc-tools
	$(eval GRPC_TOOLS_NUPKG=Grpc.Tools.$(GRPC_TOOLS_VERSION).nupkg)
	wget https://packages.grpc.io/archive/2018/11/e0d9692fa30cf3a7a8410a722693d5d3d68fb0fd-9b09b221-3b75-48ab-a39a-257224c0a252/csharp/$(GRPC_TOOLS_NUPKG)
	unzip -o $(GRPC_TOOLS_NUPKG) -d Grpc.Tools
	chmod +x Grpc.Tools/tools/$(PLATFORM)/*
	rm $(GRPC_TOOLS_NUPKG)

grpc-tools-python:
	pip install --pre --upgrade --force-reinstall --extra-index-url \
    https://packages.grpc.io/archive/2018/11/e0d9692fa30cf3a7a8410a722693d5d3d68fb0fd-6619311d-4470-4a1a-b68e-b84bacb2e22c/python \
    grpcio grpcio-{tools,health-checking,reflection,testing}

grpc-unity-package:	init-client
	$(eval GRPC_UNITY_PACKAGE=grpc_unity_package.$(GRPC_TOOLS_VERSION).zip)
	wget https://packages.grpc.io/archive/2018/11/e0d9692fa30cf3a7a8410a722693d5d3d68fb0fd-9b09b221-3b75-48ab-a39a-257224c0a252/csharp/$(GRPC_UNITY_PACKAGE)
	unzip -o $(GRPC_UNITY_PACKAGE) -d $(GRPC_CLIENT_DIR)
	rm $(GRPC_UNITY_PACKAGE)

protoc-client: grpc-tools-csharp
	protoc -I proto --csharp_out $(GRPC_CLIENT_GENERATED_DIR) --grpc_out $(GRPC_CLIENT_GENERATED_DIR) proto/*.proto --plugin=protoc-gen-grpc=Grpc.Tools/tools/$(PLATFORM)/grpc_csharp_plugin

protoc-server:
	python -m grpc_tools.protoc -I proto --python_out=server/python/ --grpc_python_out=server/python proto/helloworld.proto

clean-client:
	rm -rf $(GRPC_CLIENT_DIR) Grpc.Tools

clean-server:
	rm -f server/python/*_pb2*

clean:	clean-client	clean-server