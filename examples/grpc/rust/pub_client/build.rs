extern crate protoc_grpcio;

fn main() {
    let proto_root = "src/protos";
    println!("cargo:rerun-if-changed={}", proto_root);
    protoc_grpcio::compile_grpc_protos(
        &["common.proto", "diagnostics_api.proto",
            "functional_api.proto", "network_api.proto", "system_api.proto"],
        &[proto_root],
        &proto_root,
        None,
    ).expect("Failed to compile gRPC definitions!")
}
