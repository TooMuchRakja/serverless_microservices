import boto3
import os
import pytest
import time
import json
import subprocess
from datetime import datetime
from decimal import Decimal

globalConfig = {}

def get_stack_outputs():
    output = subprocess.check_output(['terraform', 'output'], universal_newlines=True)

    # Create a dictionary from the output
    result = {}
    for line in output.strip().split('\n'):
        key, value = line.split(' = ')
        result[key.strip()] = value.strip().replace('"','')
    
    return result

def load_test_order():
    with open('pooling_service/tests/integration/order.json') as f:
        test_order = json.load(f)
    test_order['data']['userId'] = globalConfig['regularUserSub']

    return test_order

def create_cognito_accounts():
    result = {}
    sm_client = boto3.client('secretsmanager')
    idp_client = boto3.client('cognito-idp')
    # create regular user account
    sm_response = sm_client.get_random_password(
        ExcludeCharacters='"' '`[]{}():;,$/\\<>|=&', RequireEachIncludedType=True
    )
    result["regularUserName"] = "regularUser@example.com"
    result["regularUserPassword"] = sm_response["RandomPassword"]
    try:
        idp_client.admin_delete_user(
            UserPoolId=globalConfig["UserPool"], Username=result["regularUserName"]
        )
    except idp_client.exceptions.UserNotFoundException:
        print('Regular user haven\'t been created previously')
    idp_response = idp_client.sign_up(
        ClientId=globalConfig["UserPoolClient"],
        Username=result["regularUserName"],
        Password=result["regularUserPassword"],
        UserAttributes=[{"Name": "name", "Value": result["regularUserName"]}],
    )
    result["regularUserSub"] = idp_response["UserSub"]
    idp_client.admin_confirm_sign_up(
        UserPoolId=globalConfig["UserPool"], Username=result["regularUserName"]
    )
    # get new user authentication info
    idp_response = idp_client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': result["regularUserName"],
            'PASSWORD': result["regularUserPassword"],
        },
        ClientId=globalConfig["UserPoolClient"],
    )
    result["regularUserIdToken"] = idp_response["AuthenticationResult"]["IdToken"]
    result["regularUserAccessToken"] = idp_response["AuthenticationResult"][
        "AccessToken"
    ]
    result["regularUserRefreshToken"] = idp_response["AuthenticationResult"][
        "RefreshToken"
    ]

    return result


def clear_dynamo_tables():
    # clear all data from the tables that will be used for testing
    dbd_client = boto3.client('dynamodb')
    db_response = dbd_client.scan(
        TableName=globalConfig['orders_dynamodb_table_name'], AttributesToGet=['orderId', 'userId']
    )

    for item in db_response["Items"]:
        dbd_client.delete_item(
            TableName=globalConfig['orders_dynamodb_table_name'],
            Key={
                'userId': {'S': globalConfig['regularUserSub']},
                'orderId': {'S': item['orderId']["S"]},
            },
        )
    return


def seed_dynamo_tables():
    
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(globalConfig['orders_dynamodb_table_name'])
    
    
    test_order = globalConfig["order"]
    order_id = test_order["data"]['orderId']
    user_id = globalConfig['regularUserSub']
    ddb_item = {
        'orderId': order_id,
        'userId': user_id,
        'data': {
            'orderId': order_id,
            'userId': user_id,
            'restaurantId': test_order["data"]["restaurantId"],
            'totalAmount': test_order["data"]["totalAmount"],
            'orderItems': test_order["data"]["orderItems"],
            'status': test_order["data"]['status'],
            'orderTime': test_order["data"]['orderTime']
        }
    }

    ddb_item = json.loads(json.dumps(ddb_item), parse_float=Decimal)

    table.put_item(Item=ddb_item)
    

@pytest.fixture(scope='session')
def global_config(request):
    global globalConfig
    globalConfig.update(get_stack_outputs()) # tutaj outputy z terraforma dodawane są do słownika globla config
    globalConfig.update(create_cognito_accounts())
    globalConfig['order'] = load_test_order()
    seed_dynamo_tables()
    yield globalConfig
    clear_dynamo_tables()

