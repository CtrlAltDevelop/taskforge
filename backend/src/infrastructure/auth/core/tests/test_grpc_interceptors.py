"""The gRPC server refuses to start unless every configured interceptor is a real object."""

import grpc
from django_socio_grpc.settings import grpc_settings


def test_configured_server_interceptors_are_what_grpc_aio_accepts() -> None:
    interceptors = grpc_settings.SERVER_INTERCEPTORS
    assert interceptors, "the DPoP method-path interceptor must be registered"
    for interceptor in interceptors:
        assert isinstance(interceptor, grpc.aio.ServerInterceptor), interceptor
