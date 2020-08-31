// This file is generated. Do not edit
// @generated

// https://github.com/Manishearth/rust-clippy/issues/702
#![allow(unknown_lints)]
#![allow(clippy::all)]

#![cfg_attr(rustfmt, rustfmt_skip)]

#![allow(box_pointers)]
#![allow(dead_code)]
#![allow(missing_docs)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]
#![allow(trivial_casts)]
#![allow(unsafe_code)]
#![allow(unused_imports)]
#![allow(unused_results)]

const METHOD_NETWORK_SERVICE_SUBSCRIBE_TO_SIGNALS: ::grpcio::Method<super::network_api::SubscriberConfig, super::network_api::Signals> = ::grpcio::Method {
    ty: ::grpcio::MethodType::ServerStreaming,
    name: "/base.NetworkService/SubscribeToSignals",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_NETWORK_SERVICE_PUBLISH_SIGNALS: ::grpcio::Method<super::network_api::PublisherConfig, super::common::Empty> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.NetworkService/PublishSignals",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_NETWORK_SERVICE_READ_SIGNALS: ::grpcio::Method<super::network_api::SignalIds, super::network_api::Signals> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.NetworkService/ReadSignals",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

#[derive(Clone)]
pub struct NetworkServiceClient {
    client: ::grpcio::Client,
}

impl NetworkServiceClient {
    pub fn new(channel: ::grpcio::Channel) -> Self {
        NetworkServiceClient {
            client: ::grpcio::Client::new(channel),
        }
    }

    pub fn subscribe_to_signals_opt(&self, req: &super::network_api::SubscriberConfig, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientSStreamReceiver<super::network_api::Signals>> {
        self.client.server_streaming(&METHOD_NETWORK_SERVICE_SUBSCRIBE_TO_SIGNALS, req, opt)
    }

    pub fn subscribe_to_signals(&self, req: &super::network_api::SubscriberConfig) -> ::grpcio::Result<::grpcio::ClientSStreamReceiver<super::network_api::Signals>> {
        self.subscribe_to_signals_opt(req, ::grpcio::CallOption::default())
    }

    pub fn publish_signals_opt(&self, req: &super::network_api::PublisherConfig, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Empty> {
        self.client.unary_call(&METHOD_NETWORK_SERVICE_PUBLISH_SIGNALS, req, opt)
    }

    pub fn publish_signals(&self, req: &super::network_api::PublisherConfig) -> ::grpcio::Result<super::common::Empty> {
        self.publish_signals_opt(req, ::grpcio::CallOption::default())
    }

    pub fn publish_signals_async_opt(&self, req: &super::network_api::PublisherConfig, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.client.unary_call_async(&METHOD_NETWORK_SERVICE_PUBLISH_SIGNALS, req, opt)
    }

    pub fn publish_signals_async(&self, req: &super::network_api::PublisherConfig) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.publish_signals_async_opt(req, ::grpcio::CallOption::default())
    }

    pub fn read_signals_opt(&self, req: &super::network_api::SignalIds, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::network_api::Signals> {
        self.client.unary_call(&METHOD_NETWORK_SERVICE_READ_SIGNALS, req, opt)
    }

    pub fn read_signals(&self, req: &super::network_api::SignalIds) -> ::grpcio::Result<super::network_api::Signals> {
        self.read_signals_opt(req, ::grpcio::CallOption::default())
    }

    pub fn read_signals_async_opt(&self, req: &super::network_api::SignalIds, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::network_api::Signals>> {
        self.client.unary_call_async(&METHOD_NETWORK_SERVICE_READ_SIGNALS, req, opt)
    }

    pub fn read_signals_async(&self, req: &super::network_api::SignalIds) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::network_api::Signals>> {
        self.read_signals_async_opt(req, ::grpcio::CallOption::default())
    }
    pub fn spawn<F>(&self, f: F) where F: ::futures::Future<Output = ()> + Send + 'static {
        self.client.spawn(f)
    }
}

pub trait NetworkService {
    fn subscribe_to_signals(&mut self, ctx: ::grpcio::RpcContext, req: super::network_api::SubscriberConfig, sink: ::grpcio::ServerStreamingSink<super::network_api::Signals>);
    fn publish_signals(&mut self, ctx: ::grpcio::RpcContext, req: super::network_api::PublisherConfig, sink: ::grpcio::UnarySink<super::common::Empty>);
    fn read_signals(&mut self, ctx: ::grpcio::RpcContext, req: super::network_api::SignalIds, sink: ::grpcio::UnarySink<super::network_api::Signals>);
}

pub fn create_network_service<S: NetworkService + Send + Clone + 'static>(s: S) -> ::grpcio::Service {
    let mut builder = ::grpcio::ServiceBuilder::new();
    let mut instance = s.clone();
    builder = builder.add_server_streaming_handler(&METHOD_NETWORK_SERVICE_SUBSCRIBE_TO_SIGNALS, move |ctx, req, resp| {
        instance.subscribe_to_signals(ctx, req, resp)
    });
    let mut instance = s.clone();
    builder = builder.add_unary_handler(&METHOD_NETWORK_SERVICE_PUBLISH_SIGNALS, move |ctx, req, resp| {
        instance.publish_signals(ctx, req, resp)
    });
    let mut instance = s;
    builder = builder.add_unary_handler(&METHOD_NETWORK_SERVICE_READ_SIGNALS, move |ctx, req, resp| {
        instance.read_signals(ctx, req, resp)
    });
    builder.build()
}
