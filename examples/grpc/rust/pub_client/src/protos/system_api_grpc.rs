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

const METHOD_SYSTEM_SERVICE_GET_CONFIGURATION: ::grpcio::Method<super::common::Empty, super::common::Configuration> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.SystemService/GetConfiguration",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

const METHOD_SYSTEM_SERVICE_LIST_SIGNALS: ::grpcio::Method<super::common::NameSpace, super::common::Frames> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.SystemService/ListSignals",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

#[derive(Clone)]
pub struct SystemServiceClient {
    client: ::grpcio::Client,
}

impl SystemServiceClient {
    pub fn new(channel: ::grpcio::Channel) -> Self {
        SystemServiceClient {
            client: ::grpcio::Client::new(channel),
        }
    }

    pub fn get_configuration_opt(&self, req: &super::common::Empty, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Configuration> {
        self.client.unary_call(&METHOD_SYSTEM_SERVICE_GET_CONFIGURATION, req, opt)
    }

    pub fn get_configuration(&self, req: &super::common::Empty) -> ::grpcio::Result<super::common::Configuration> {
        self.get_configuration_opt(req, ::grpcio::CallOption::default())
    }

    pub fn get_configuration_async_opt(&self, req: &super::common::Empty, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Configuration>> {
        self.client.unary_call_async(&METHOD_SYSTEM_SERVICE_GET_CONFIGURATION, req, opt)
    }

    pub fn get_configuration_async(&self, req: &super::common::Empty) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Configuration>> {
        self.get_configuration_async_opt(req, ::grpcio::CallOption::default())
    }

    pub fn list_signals_opt(&self, req: &super::common::NameSpace, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::common::Frames> {
        self.client.unary_call(&METHOD_SYSTEM_SERVICE_LIST_SIGNALS, req, opt)
    }

    pub fn list_signals(&self, req: &super::common::NameSpace) -> ::grpcio::Result<super::common::Frames> {
        self.list_signals_opt(req, ::grpcio::CallOption::default())
    }

    pub fn list_signals_async_opt(&self, req: &super::common::NameSpace, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Frames>> {
        self.client.unary_call_async(&METHOD_SYSTEM_SERVICE_LIST_SIGNALS, req, opt)
    }

    pub fn list_signals_async(&self, req: &super::common::NameSpace) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::common::Frames>> {
        self.list_signals_async_opt(req, ::grpcio::CallOption::default())
    }
    pub fn spawn<F>(&self, f: F) where F: ::futures::Future<Output = ()> + Send + 'static {
        self.client.spawn(f)
    }
}

pub trait SystemService {
    fn get_configuration(&mut self, ctx: ::grpcio::RpcContext, req: super::common::Empty, sink: ::grpcio::UnarySink<super::common::Configuration>);
    fn list_signals(&mut self, ctx: ::grpcio::RpcContext, req: super::common::NameSpace, sink: ::grpcio::UnarySink<super::common::Frames>);
}

pub fn create_system_service<S: SystemService + Send + Clone + 'static>(s: S) -> ::grpcio::Service {
    let mut builder = ::grpcio::ServiceBuilder::new();
    let mut instance = s.clone();
    builder = builder.add_unary_handler(&METHOD_SYSTEM_SERVICE_GET_CONFIGURATION, move |ctx, req, resp| {
        instance.get_configuration(ctx, req, resp)
    });
    let mut instance = s;
    builder = builder.add_unary_handler(&METHOD_SYSTEM_SERVICE_LIST_SIGNALS, move |ctx, req, resp| {
        instance.list_signals(ctx, req, resp)
    });
    builder.build()
}
