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

const METHOD_FUNCTIONAL_SERVICE_OPEN_PASS_WINDOW: ::grpcio::Method<super::common::ClientId, super::common::Empty> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.FunctionalService/OpenPassWindow",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_FUNCTIONAL_SERVICE_CLOSE_PASS_WINDOW: ::grpcio::Method<super::common::ClientId, super::common::Empty> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.FunctionalService/ClosePassWindow",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_FUNCTIONAL_SERVICE_SET_FAN_SPEED: ::grpcio::Method<super::functional_api::SenderInfo, super::common::Empty> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.FunctionalService/SetFanSpeed",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_FUNCTIONAL_SERVICE_SUBSCRIBE_TO_FAN_SPEED: ::grpcio::Method<super::functional_api::SubscriberRequest, super::functional_api::Value> = ::grpcio::Method {
    ty: ::grpcio::MethodType::ServerStreaming,
    name: "/base.FunctionalService/SubscribeToFanSpeed",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

#[derive(Clone)]
pub struct FunctionalServiceClient {
    client: ::grpcio::Client,
}

impl FunctionalServiceClient {
    pub fn new(channel: ::grpcio::Channel) -> Self {
        FunctionalServiceClient {
            client: ::grpcio::Client::new(channel),
        }
    }

    pub fn open_pass_window_opt(&self, req: &super::common::ClientId, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Empty> {
        self.client.unary_call(&METHOD_FUNCTIONAL_SERVICE_OPEN_PASS_WINDOW, req, opt)
    }

    pub fn open_pass_window(&self, req: &super::common::ClientId) -> ::grpcio::Result<super::common::Empty> {
        self.open_pass_window_opt(req, ::grpcio::CallOption::default())
    }

    pub fn open_pass_window_async_opt(&self, req: &super::common::ClientId, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.client.unary_call_async(&METHOD_FUNCTIONAL_SERVICE_OPEN_PASS_WINDOW, req, opt)
    }

    pub fn open_pass_window_async(&self, req: &super::common::ClientId) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.open_pass_window_async_opt(req, ::grpcio::CallOption::default())
    }

    pub fn close_pass_window_opt(&self, req: &super::common::ClientId, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Empty> {
        self.client.unary_call(&METHOD_FUNCTIONAL_SERVICE_CLOSE_PASS_WINDOW, req, opt)
    }

    pub fn close_pass_window(&self, req: &super::common::ClientId) -> ::grpcio::Result<super::common::Empty> {
        self.close_pass_window_opt(req, ::grpcio::CallOption::default())
    }

    pub fn close_pass_window_async_opt(&self, req: &super::common::ClientId, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.client.unary_call_async(&METHOD_FUNCTIONAL_SERVICE_CLOSE_PASS_WINDOW, req, opt)
    }

    pub fn close_pass_window_async(&self, req: &super::common::ClientId) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.close_pass_window_async_opt(req, ::grpcio::CallOption::default())
    }

    pub fn set_fan_speed_opt(&self, req: &super::functional_api::SenderInfo, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Empty> {
        self.client.unary_call(&METHOD_FUNCTIONAL_SERVICE_SET_FAN_SPEED, req, opt)
    }

    pub fn set_fan_speed(&self, req: &super::functional_api::SenderInfo) -> ::grpcio::Result<super::common::Empty> {
        self.set_fan_speed_opt(req, ::grpcio::CallOption::default())
    }

    pub fn set_fan_speed_async_opt(&self, req: &super::functional_api::SenderInfo, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.client.unary_call_async(&METHOD_FUNCTIONAL_SERVICE_SET_FAN_SPEED, req, opt)
    }

    pub fn set_fan_speed_async(&self, req: &super::functional_api::SenderInfo) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Empty>> {
        self.set_fan_speed_async_opt(req, ::grpcio::CallOption::default())
    }

    pub fn subscribe_to_fan_speed_opt(&self, req: &super::functional_api::SubscriberRequest, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientSStreamReceiver<super::functional_api::Value>> {
        self.client.server_streaming(&METHOD_FUNCTIONAL_SERVICE_SUBSCRIBE_TO_FAN_SPEED, req, opt)
    }

    pub fn subscribe_to_fan_speed(&self, req: &super::functional_api::SubscriberRequest) -> ::grpcio::Result<::grpcio::ClientSStreamReceiver<super::functional_api::Value>> {
        self.subscribe_to_fan_speed_opt(req, ::grpcio::CallOption::default())
    }
    pub fn spawn<F>(&self, f: F) where F: ::futures::Future<Output = ()> + Send + 'static {
        self.client.spawn(f)
    }
}

pub trait FunctionalService {
    fn open_pass_window(&mut self, ctx: ::grpcio::RpcContext, req: super::common::ClientId, sink: ::grpcio::UnarySink<super::common::Empty>);
    fn close_pass_window(&mut self, ctx: ::grpcio::RpcContext, req: super::common::ClientId, sink: ::grpcio::UnarySink<super::common::Empty>);
    fn set_fan_speed(&mut self, ctx: ::grpcio::RpcContext, req: super::functional_api::SenderInfo, sink: ::grpcio::UnarySink<super::common::Empty>);
    fn subscribe_to_fan_speed(&mut self, ctx: ::grpcio::RpcContext, req: super::functional_api::SubscriberRequest, sink: ::grpcio::ServerStreamingSink<super::functional_api::Value>);
}

pub fn create_functional_service<S: FunctionalService + Send + Clone + 'static>(s: S) -> ::grpcio::Service {
    let mut builder = ::grpcio::ServiceBuilder::new();
    let mut instance = s.clone();
    builder = builder.add_unary_handler(&METHOD_FUNCTIONAL_SERVICE_OPEN_PASS_WINDOW, move |ctx, req, resp| {
        instance.open_pass_window(ctx, req, resp)
    });
    let mut instance = s.clone();
    builder = builder.add_unary_handler(&METHOD_FUNCTIONAL_SERVICE_CLOSE_PASS_WINDOW, move |ctx, req, resp| {
        instance.close_pass_window(ctx, req, resp)
    });
    let mut instance = s.clone();
    builder = builder.add_unary_handler(&METHOD_FUNCTIONAL_SERVICE_SET_FAN_SPEED, move |ctx, req, resp| {
        instance.set_fan_speed(ctx, req, resp)
    });
    let mut instance = s;
    builder = builder.add_server_streaming_handler(&METHOD_FUNCTIONAL_SERVICE_SUBSCRIBE_TO_FAN_SPEED, move |ctx, req, resp| {
        instance.subscribe_to_fan_speed(ctx, req, resp)
    });
    builder.build()
}
