# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3
import os
import pytest
import time
import subprocess

globalConfig = {}

def get_stack_outputs():
    output = subprocess.check_output(['terraform', 'output'], universal_newlines=True)

    # Create a dictionary from the output
    result = {}
    for line in output.strip().split('\n'):
        key, value = line.split(' = ')
        result[key.strip()] = value.strip().replace('"','')
    
    return result

def create_cognito_accounts():
    result = {}
    sm_client = boto3.client('secretsmanager')
    idp_client = boto3.client('cognito-idp')

    # create single user account
    sm_response = sm_client.get_random_password(ExcludeCharacters='"''`[]{}():;,$/\\<>|=&',
                                                RequireEachIncludedType=True)
    result["user1UserName"] = "user1@example.com"
    result["user1UserPassword"] = sm_response["RandomPassword"]

    try:
        idp_client.admin_delete_user(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user1UserName"])
    except idp_client.exceptions.UserNotFoundException:
        print('User has not been created previously')

    # sign up the user
    idp_response = idp_client.sign_up(
        ClientId=globalConfig["UserPoolClient"],
        Username=result["user1UserName"],
        Password=result["user1UserPassword"],
        UserAttributes=[{"Name": "name", "Value": result["user1UserName"]}]
    )
    result["user1UserSub"] = idp_response["UserSub"]

    # confirm sign-up
    idp_client.admin_confirm_sign_up(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user1UserName"])

    # get authentication tokens
    idp_response = idp_client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': result["user1UserName"],
            'PASSWORD': result["user1UserPassword"]
        },
        ClientId=globalConfig["UserPoolClient"],
    )

    result["user1UserIdToken"] = idp_response["AuthenticationResult"]["IdToken"]
    result["user1AccessToken"] = idp_response["AuthenticationResult"]["AccessToken"]
    result["user1RefreshToken"] = idp_response["AuthenticationResult"]["RefreshToken"]

    return result

def clear_dynamo_tables():
    # clear all data from the tables that will be used for testing
    dbd_client = boto3.client('dynamodb')
    db_response = dbd_client.scan(
        TableName=globalConfig['orders_dynamodb_table_name'],
        AttributesToGet=['userId', 'orderId']
    )
    for item in db_response["Items"]:
        dbd_client.delete_item(
            TableName=globalConfig['orders_dynamodb_table_name'],
            Key={
                'userId': {'S': item['userId']["S"]},
                'orderId': {'S': item['orderId']["S"]}
            }
        )
    return

@pytest.fixture(scope='session')
def global_config(request):
    global globalConfig
    # load outputs of the stacks to test
    globalConfig.update(get_stack_outputs())
    globalConfig.update(create_cognito_accounts())
    clear_dynamo_tables()
    return globalConfig