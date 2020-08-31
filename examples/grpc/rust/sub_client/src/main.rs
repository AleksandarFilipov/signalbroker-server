pub mod protos;

use grpcio::{ChannelBuilder, EnvBuilder};
use std::sync::{Arc};
use protobuf::{SingularPtrField, RepeatedField};
use futures::{StreamExt};
use futures::executor::{block_on};
use crate::protos::network_api_grpc::NetworkServiceClient;
use crate::protos::common::{NameSpace, SignalId, ClientId};
use crate::protos::network_api::{SignalIds, SubscriberConfig};

// Create a subscribing stream from set of signalIDs to signal-server
async fn subscribe_to_signals(client: &NetworkServiceClient) {
    let mut client_id = ClientId::new();
    client_id.id = "rusty_client_sub".to_string();

    let mut subscriber_config = SubscriberConfig::new();
    subscriber_config.clientId = SingularPtrField::some(client_id);
    subscriber_config.signals = generate_signal_ids();

    println!("Subscribing to {:?}", subscriber_config.signals);

    let mut sub_info = client.subscribe_to_signals(&subscriber_config).unwrap();
    while let Some(signals) = sub_info.next().await {
        println!("Received {:?}", signals.unwrap().signal.to_vec())
    }
}

// Generating set of SignalsIDs, for subscriptions
fn generate_signal_ids() -> SingularPtrField<SignalIds> {
    let mut namespace = NameSpace::new();
    namespace.name = "VirtualInterface".to_string();

    let mut signal_id = SignalId::new();
    signal_id.name = "virtual_signal".to_string();
    signal_id.namespace = SingularPtrField::some(namespace);

    let signal_ids_vector = vec![signal_id];

    let mut signal_ids = SignalIds::new();
    signal_ids.signalId = RepeatedField::from_vec(signal_ids_vector);

    SingularPtrField::some(signal_ids)
}

fn main() {
    let env = Arc::new(EnvBuilder::new().build());
    let channel = ChannelBuilder::new(env).connect(format!("localhost:50051").as_str());
    let client = NetworkServiceClient::new(channel);

    loop {
        block_on(async { subscribe_to_signals(&client).await })
    };
}
