
# Rust gRPC signal-broker example

In this folder, you will find two examples, one subscriber example, and one publisher example

## Setup
1. Download and install rust https://www.rust-lang.org/
2 Choose an IDE of your choice I will suggest that you use either
* VSCode with the Rust extension
* Jetbrains IDE with the Rust plugin
3. Copy the proto files from signalbroker-server/apps/grpc_service/protofiles and add them to the folders pub_client/src/protos/ and sub_client/src/protos/

The cargo build system will download and install all necessary dependencies that are declared in Cargo.toml file

## How to use
From a terminal, simply run:
```
cargo run 
```
inside either folder pub_client or sub_client

### Cross-compile Rust
For cross-compilation, please have a look at these sites

https://doc.rust-lang.org/rustc/targets/index.html
https://doc.rust-lang.org/nightly/nightly-rustc/rustc_target/spec/index.html#modules