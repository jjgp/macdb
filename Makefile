# Attribution: https://github.com/grpc/grpc-swift/blob/nio/Makefile

PROTOC_GEN_SWIFT=bin/protoc-gen-swift
PROTOC_GEN_GRPC_SWIFT=bin/protoc-gen-grpc-swift

%.pb.swift: %.proto ${PROTOC_GEN_SWIFT}
	protoc $< \
		--proto_path=$(dir $<) \
		--plugin=${PROTOC_GEN_SWIFT} \
		--swift_opt=Visibility=Public \
		--swift_out=$(dir $<)

%.grpc.swift: %.proto ${PROTOC_GEN_GRPC_SWIFT}
	protoc $< \
		--proto_path=$(dir $<) \
		--plugin=${PROTOC_GEN_GRPC_SWIFT} \
		--grpc-swift_opt=Visibility=Public \
		--grpc-swift_out=$(dir $<)

MACDB_PROTO=Sources/macdb/Model/macdb.proto
MACDB_PB=$(MACDB_PROTO:.proto=.pb.swift)
MACDB_GRPC=$(MACDB_PROTO:.proto=.grpc.swift)

# Generates protobufs and gRPC client and server for macdb
.PHONY:
generate-macb: ${MACDB_PB} ${MACDB_GRPC}
