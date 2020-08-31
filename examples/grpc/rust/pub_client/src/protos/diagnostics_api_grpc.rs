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

const METHOD_DIAGNOSTICS_SERVICE_SEND_DIAGNOSTICS_QUERY: ::grpcio::Method<super::diagnostics_api::DiagnosticsRequest, super::diagnostics_api::DiagnosticsResponse> = ::grpcio::Method {
    ty: ::grpcio::MethodType::Unary,
    name: "/base.DiagnosticsService/SendDiagnosticsQuery",
    req_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
    resp_mar: ::grpcio::Marshaller { ser: ::grpcio::pb_ser, de: ::grpcio::pb_de },
};

#[derive(Clone)]
pub struct DiagnosticsServiceClient {
    client: ::grpcio::Client,
}

impl DiagnosticsServiceClient {
    pub fn new(channel: ::grpcio::Channel) -> Self {
        DiagnosticsServiceClient {
            client: ::grpcio::Client::new(channel),
        }
    }

    pub fn send_diagnostics_query_opt(&self, req: &super::diagnostics_api::DiagnosticsRequest, opt: ::grpcio::CallOption) -> ::grpcio::Result<super::diagnostics_api::DiagnosticsResponse> {
        self.client.unary_call(&METHOD_DIAGNOSTICS_SERVICE_SEND_DIAGNOSTICS_QUERY, req, opt)
    }

    pub fn send_diagnostics_query(&self, req: &super::diagnostics_api::DiagnosticsRequest) -> ::grpcio::Result<super::diagnostics_api::DiagnosticsResponse> {
        self.send_diagnostics_query_opt(req, ::grpcio::CallOption::default())
    }

    pub fn send_diagnostics_query_async_opt(&self, req: &super::diagnostics_api::DiagnosticsRequest, opt: ::grpcio::CallOption) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::diagnostics_api::DiagnosticsResponse>> {
        self.client.unary_call_async(&METHOD_DIAGNOSTICS_SERVICE_SEND_DIAGNOSTICS_QUERY, req, opt)
    }

    pub fn send_diagnostics_query_async(&self, req: &super::diagnostics_api::DiagnosticsRequest) -> ::grpcio::Result<::grpcio::ClientUnaryReceiver<super::diagnostics_api::DiagnosticsResponse>> {
        self.send_diagnostics_query_async_opt(req, ::grpcio::CallOption::default())
    }
    pub fn spawn<F>(&self, f: F) where F: ::futures::Future<Output = ()> + Send + 'static {
        self.client.spawn(f)
    }
}

pub trait DiagnosticsService {
    fn send_diagnostics_query(&mut self, ctx: ::grpcio::RpcContext, req: super::diagnostics_api::DiagnosticsRequest, sink: ::grpcio::UnarySink<super::diagnostics_api::DiagnosticsResponse>);
}

pub fn create_diagnostics_service<S: DiagnosticsService + Send + Clone + 'static>(s: S) -> ::grpcio::Service {
    let mut builder = ::grpcio::ServiceBuilder::new();
    let mut instance = s;
    builder = builder.add_unary_handler(&METHOD_DIAGNOSTICS_SERVICE_SEND_DIAGNOSTICS_QUERY, move |ctx, req, resp| {
        instance.send_diagnostics_query(ctx, req, resp)
    });
    builder.build()
}
