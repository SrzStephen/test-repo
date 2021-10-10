from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.logging import correlation_paths
from aws_lambda_powertools.event_handler.api_gateway import ApiGatewayResolver, ProxyEventType
from aws_lambda_powertools.event_handler.exceptions import (
    BadRequestError,
    InternalServerError,
    NotFoundError,
    ServiceError,
    UnauthorizedError,
)

app = ApiGatewayResolver()


@app.post('/phone/battery')
def send_battery():
    return dict(body=dict(
        event=app.current_event.__str__()))


@app.post('/phone/gps')
def send_gps():
    print("CAME IN HERE")
    return dict(body=dict(
        event=app.current_event.__str__()))


@app.post('/phone/display')
def send_phone_state():
    return dict(body=dict(
        event=app.current_event.__str__()))


@app.post(".+")
def catch_any_route_after_any():
    return {"path_received": app.current_event.path}


def lambda_handler(event, context):
    print(event)
    print(context)
    return app.resolve(event, context)
