protoc-gen-validate:
	rm -f protoc-gen-validate && mix escript.build .

gen-protos: protoc-gen-validate
	protoc -I deps/protoc_gen_validate/validate --elixir_out=lib validate.proto
	protoc -I src -I test/proto --elixir_out=test/proto_gen test/proto/*.proto
	protoc -I src -I test/proto --validate_out=test/proto_gen --plugin=./protoc-gen-validate test/proto/*.proto

.PHONY: protoc-gen-validate gen-protos
