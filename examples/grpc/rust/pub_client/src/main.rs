pub mod protos;

use grpcio::{ChannelBuilder, EnvBuilder};
use std::sync::{Arc};
use protobuf::{SingularPtrField, RepeatedField};
use futures::executor::{block_on};
use crate::protos::network_api_grpc::NetworkServiceClient;
use crate::protos::common::{NameSpace, SignalId, ClientId};
use crate::protos::network_api::{Signal, Signals, PublisherConfig, Signal_oneof_payload};
use std::io::Write;

// Publish signals to signal-broker over gRPC
async fn publish_signals(client: &NetworkServiceClient) {
    let mut client_id = ClientId::new();
    client_id.id = "rusty_client_pub".to_string();

    print!("Enter a value: ");
    std::io::stdout().flush().ok().expect("Failed to flush output stream");

    // Take input from terminal
    let mut input_string = String::new();
    let _input_result = std::io::stdin().read_line(&mut input_string);

    // try to parse the string into int64, if fail: payload = 0
    let input_as_int: i64 = input_string.trim().parse().unwrap_or(0);

    // Create a PublisherConfig from .proto files
    let mut publisher_config = PublisherConfig::new();
    publisher_config.clientId = SingularPtrField::some(client_id);
    publisher_config.signals = generate_signals(&input_as_int);
    let _result = client.publish_signals_async(&publisher_config).unwrap().await;
}

// Generating set of Signals, for publishing
fn generate_signals(payload: &i64) -> SingularPtrField<Signals> {
    let mut namespace = NameSpace::new();
    namespace.name = "VirtualInterface".to_string();

    let mut signal_id = SignalId::new();
    signal_id.name = "virtual_signal".to_string();
    signal_id.namespace = SingularPtrField::some(namespace);

    let mut signal = Signal::new();
    signal.id = SingularPtrField::some(signal_id);
    signal.payload = Option::from(Signal_oneof_payload::integer(*payload));

    let signals_vector = vec![signal];

    let mut signals = Signals::new();
    signals.signal = RepeatedField::from_vec(signals_vector);

    SingularPtrField::some(signals)
}

fn main() {
    let env = Arc::new(EnvBuilder::new().build());
    let channel = ChannelBuilder::new(env).connect(format!("localhost:50051").as_str());
    let client = NetworkServiceClient::new(channel);

    loop {
        block_on(async { publish_signals(&client).await })
    };
}
