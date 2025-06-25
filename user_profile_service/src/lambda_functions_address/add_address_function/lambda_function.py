import json
import os
import boto3
import uuid
from aws_lambda_powertools import Logger, Tracer

# Globals
logger = Logger()
tracer = Tracer(service="APP")
address_table = os.getenv('ADDRESS_TABLE_NAME')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(address_table)

@tracer.capture_method 
def add_address(event, context):
    logger.info(f"Full event: {event}")
    
    try:
        detail = event['detail']
        line1 = detail['line1']
        line2 = detail['line2']
        city = detail['city']
        state_province = detail['stateProvince']
        postal = detail['postal']
        user_id = detail['userId']
        logger.info(f"Saving address for user {user_id}: {line1}, {line2}, {city}, {state_province}, {postal} to DynamoDb {address_table}")
        
    except (KeyError, json.JSONDecodeError, TypeError) as err:
        logger.exception("Invalid event format")
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid or missing address fields"})
        }

    address_id = str(uuid.uuid4())
    table.put_item(
        Item={
            'address_id': address_id,
            'user_id': user_id,
            'line1': line1,
            'line2': line2,
            'city': city,
            'stateProvince': state_province,
            'postal': postal
        }
    )
    logger.info(f"Address with ID {address_id} saved")
    
    return {
        "statusCode": 200,
        "body": json.dumps({"address_id": address_id})
    }

@tracer.capture_lambda_handler
def lambda_handler(event, context):
    try:
        return add_address(event, context)
    except Exception as err:
        logger.exception(err)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }
