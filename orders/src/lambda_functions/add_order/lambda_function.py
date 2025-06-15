import os
import boto3
import json
import uuid
from decimal import Decimal
from datetime import datetime

from aws_lambda_powertools import Logger, Metrics
from aws_lambda_powertools.metrics import MetricUnit
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.utilities.idempotency import (
    IdempotencyConfig,
    DynamoDBPersistenceLayer,
    idempotent_function
)

# Logger and metrics setup
logger = Logger()
metrics = Metrics()

# Environment variables
orders_table = os.getenv('ORDERS_TABLE')
idempotency_table = os.getenv('IDEMPOTENCY_TABLE_NAME')

# DynamoDB client
dynamodb = boto3.resource('dynamodb')

# Idempotency setup
persistence_layer = DynamoDBPersistenceLayer(table_name=idempotency_table)
idempotency_config = IdempotencyConfig(
    event_key_jmespath="body.orderId"
)


@idempotent_function(data_keyword_argument="event", config=idempotency_config, persistence_store=persistence_layer)
def add_order(event: dict):
    logger.info("Adding a new order")
    logger.info({"operation": "add_order", "order_details": detail})
    detail = json.loads(event['body'])
    restaurant_id = detail['restaurantId']
    total_amount = detail['totalAmount']
    order_items = detail['orderItems']
    user_id =  event['requestContext']['authorizer']['claims']['sub']
    order_time = datetime.strftime(datetime.utcnow(), '%Y-%m-%dT%H:%M:%SZ')
    order_id = detail['orderId']

    # Prepare DynamoDB item
    ddb_item = {
        'orderId': order_id,
        'userId': user_id,
        'data': {
            'orderId': order_id,
            'userId': user_id,
            'restaurantId': restaurant_id,
            'totalAmount': total_amount,
            'orderItems': order_items,
            'status': 'PLACED',
            'orderTime': order_time,
        }
    }
    ddb_item = json.loads(json.dumps(ddb_item), parse_float=Decimal)

    table = dynamodb.Table(orders_table)
    table.put_item(
        Item=ddb_item,
        ConditionExpression='attribute_not_exists(orderId)'
    )

    logger.info(f"New order with ID {order_id} saved")
    metrics.add_metric(name="SuccessfulOrder", unit=MetricUnit.Count, value=1)
    metrics.add_metric(name="OrderTotal", unit=MetricUnit.Count, value=total_amount)

    # Augment response
    detail['orderId'] = order_id
    detail['userId'] = user_id
    detail['status'] = 'PLACED'
    detail['orderTime'] = order_time

    return detail


@metrics.log_metrics  # ensures metrics are flushed upon request completion/failure
@logger.inject_lambda_context
def lambda_handler(event, context: LambdaContext):
    """Handles the Lambda method invocation"""
    idempotency_config.register_lambda_context(context)

    try:
        logger.debug(f"Received event: {json.dumps(event)}")
        order_detail = add_order(event=event)

        response = {
            "statusCode": 200,
            "headers": {},
            "body": json.dumps(order_detail)
        }
        return response
    except Exception as err:
        raise