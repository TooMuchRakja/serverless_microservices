import os
import boto3
from decimal import Decimal
import json
import uuid
from datetime import datetime

from aws_lambda_powertools import Logger, Metrics
from aws_lambda_powertools.metrics import MetricUnit

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws_lambda_powertools.utilities.idempotency import (
    IdempotencyConfig, DynamoDBPersistenceLayer, idempotent_function
)

logger = Logger() 
metrics = Metrics() # it will take POWERTOOLS_METRICS_NAMESPACE AUTOMATICALLY 
orders_table = os.getenv('ORDERS_TABLE')
idempotency_table = os.getenv('IDEMPOTENCY_TABLE_NAME')
dynamodb = boto3.resource('dynamodb')

persistence_layer = DynamoDBPersistenceLayer(table_name=idempotency_table)
idempotency_config = IdempotencyConfig(
    event_key_jmespath="powertools_json(body).orderId",
    payload_validation_jmespath="powertools_json(body)"
)

@idempotent_function(data_keyword_argument="event", config=idempotency_config, persistence_store=persistence_layer)
def add_order(event: dict):
    logger.info("Adding a new order")
    try:
        detail = json.loads(event['body'])
        logger.info({"operation": "add_order", "order_details": detail})
        restaurant_id = detail['restaurantId']
        total_amount = detail['totalAmount']
        order_items = detail['orderItems']
        
        # Handle both v1 and v2 API Gateway payload formats
        if 'requestContext' in event and 'authorizer' in event['requestContext']:
            authorizer = event['requestContext']['authorizer']
            if 'jwt' in authorizer and 'claims' in authorizer['jwt']:
                # API Gateway v2 format
                user_id = authorizer['jwt']['claims']['sub']
            elif 'claims' in authorizer:
                # API Gateway v1 format
                user_id = authorizer['claims']['sub']
            else:
                logger.error("Could not extract user ID from event")
                raise ValueError("Missing user claims in request context")
        else:
            logger.error("Missing request context or authorizer")
            raise ValueError("Missing request context or authorizer")
            
        order_time = datetime.strftime(datetime.utcnow(), '%Y-%m-%dT%H:%M:%SZ')
        order_id = detail['orderId']

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
    # We must use conditional expression, otherwise put_item will always replace the original order and will never fail
    table.put_item(Item=ddb_item, ConditionExpression='attribute_not_exists(orderId) AND attribute_not_exists(userId)')

    logger.info(f"new Order with ID {order_id} saved")
    metrics.add_metric(name="SuccessfulOrder", unit=MetricUnit.Count, value=1)      #SuccessfulOrder
    metrics.add_metric(name="OrderTotal", unit=MetricUnit.Count, value=total_amount) #OrderTotal

    detail['orderId'] = order_id
    detail['userId'] = user_id
    detail['status'] = 'PLACED'
    detail['orderTime'] = order_time

    return detail

@metrics.log_metrics  # ensures metrics are flushed upon request completion/failure
@logger.inject_lambda_context
def lambda_handler(event, context: LambdaContext):
    """Handles the lambda method invocation"""
    idempotency_config.register_lambda_context(context)
    
    try:
        # Log the incoming event for debugging
        logger.debug(f"Received event: {json.dumps(event)}")
        
        order_detail = add_order(event=event)
        response = {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps(order_detail)
        }
        return response
    except Exception as err:
        logger.exception(f"Error processing order: {str(err)}")
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json"
            },
            "body": json.dumps({"error": str(err)})
        }