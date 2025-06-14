import os
import boto3
import json
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
    event_key_jmespath="orderId"  # zakładamy, że orderId jest w detail
)

@idempotent_function(data_keyword_argument="detail", config=idempotency_config, persistence_store=persistence_layer)
def add_order(detail: dict):
    logger.info("Adding a new order")
    logger.info({"operation": "add_order", "order_details": detail})

    order_id = detail['orderId']
    user_id = detail['userId']  # zakładamy, że to pole jest przesyłane
    restaurant_id = detail['restaurantId']
    total_amount = detail['totalAmount']
    order_items = detail['orderItems']
    order_time = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')

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
    detail['status'] = 'PLACED'
    detail['orderTime'] = order_time

    return detail

@metrics.log_metrics
@logger.inject_lambda_context
def lambda_handler(event, context: LambdaContext):
    idempotency_config.register_lambda_context(context)

    try:
        logger.debug(f"Received event: {json.dumps(event)}")
        body = json.loads(event.get("body", "{}"))
        order_detail = add_order(detail=body)

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(order_detail)
        }

    except Exception as err:
        logger.exception(f"Error processing order: {str(err)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": str(err)})
        }
