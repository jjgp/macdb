MACDB_PROTO=macdb.proto
CLIENT_PB=$(MACDB_PROTO:.proto=_pb.js)
CLIENT_GRPC=$(MACDB_PROTO:.proto=_grpc_web_pb.js)
GRPC_SWIFT_OUT=macdb/Sources/Model/
GRPC_WEB_OUT=frontend/model/
PROTOC_GEN_SWIFT=bin/protoc-gen-swift
PROTOC_GEN_GRPC_SWIFT=bin/protoc-gen-grpc-swift
PROTOC_GEN_GRPC_WEB=bin/protoc-gen-grpc-web
SERVER_PB=$(MACDB_PROTO:.proto=.pb.swift)
SERVER_GRPC=$(MACDB_PROTO:.proto=.grpc.swift)

%.pb.swift: %.proto ${PROTOC_GEN_SWIFT}
	protoc $< \
		--proto_path=$(dir $<) \
		--plugin=${PROTOC_GEN_SWIFT} \
		--swift_opt=Visibility=Public \
		--swift_out=$(GRPC_SWIFT_OUT)

%.grpc.swift: %.proto ${PROTOC_GEN_GRPC_SWIFT}
	protoc $< \
		--proto_path=$(dir $<) \
		--plugin=${PROTOC_GEN_GRPC_SWIFT} \
		--grpc-swift_opt=Client=false,Visibility=Public \
		--grpc-swift_out=$(GRPC_SWIFT_OUT)

%_pb.js: %.proto
	protoc $< \
  		--js_out=import_style=commonjs:$(GRPC_WEB_OUT)

%_grpc_web_pb.js: %.proto ${PROTOC_GEN_GRPC_WEB}
	protoc $< \
		--plugin=${PROTOC_GEN_GRPC_WEB} \
		--grpc-web_out=import_style=commonjs,mode=grpcwebtext:$(GRPC_WEB_OUT)

.PHONY:
bootstrap: generate-client generate-server
	pushd frontend; npm i; popd;
	pushd macdb; swift package generate-xcodeproj; popd;

.PHONY:
generate-client: ${CLIENT_PB} ${CLIENT_GRPC}

.PHONY:
generate-server: ${SERVER_PB} ${SERVER_GRPC}

.PHONY:
reset-screen-capture-permission:
	tccutil reset ScreenCapture

.PHONY:
clean:
	rm -f ${GRPC_WEB_OUT}macdb_grpc_web.js
	rm -f ${GRPC_WEB_OUT}macdb_pb.js
	rm -f ${GRPC_SWIFT_OUT}macdb.grpc.swift
	rm -f ${GRPC_SWIFT_OUT}macdb.pb.swift
	rm -rf frontend/.next/
	rm -rf frontend/node_modules/
	rm -rf macdb/.build/
	rm -rf macdb/.swiftpm/
	rm -rf macdb/macdb.xcodeproj/
