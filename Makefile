LIB_PROTOS:=$(shell find src -type f -name '*.proto')

gen-protos:
	echo $(LIB_PROTOS)
	protoc -I src --elixir_out=lib $(LIB_PROTOS)
	# protoc -I src -I protos --elixir_out=test/protobuf/protoc/proto_gen --plugin=./protoc-gen-validate test/protobuf/protoc/proto/*.proto
	protoc -I src -I test/proto --elixir_out=test/proto_gen test/proto/*.proto
