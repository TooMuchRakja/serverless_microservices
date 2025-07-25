import boto3
import logging
import os
import pytest
import json
import subprocess

globalConfig = {}
LOGGER = logging.getLogger(__name__)

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
    # create regular user account
    sm_response = sm_client.get_random_password(ExcludeCharacters='"''`[]{}():;,$/\\<>|=&',
                                                RequireEachIncludedType=True)
    result["user1UserName"] = "user1User@example.com"
    result["user1UserPassword"] = sm_response["RandomPassword"]
    try:
        idp_client.admin_delete_user(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user1UserName"])
    except idp_client.exceptions.UserNotFoundException:
        print('user1 user haven''t been created previously')
    idp_response = idp_client.sign_up(
        ClientId=globalConfig["UserPoolClient"],
        Username=result["user1UserName"],
        Password=result["user1UserPassword"],
        UserAttributes=[{"Name": "name", "Value": result["user1UserName"]}]
    )
    result["user1UserSub"] = idp_response["UserSub"]
    idp_client.admin_confirm_sign_up(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user1UserName"])
    # get new user authentication info
    idp_response = idp_client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': result["user1UserName"],
            'PASSWORD': result["user1UserPassword"]
        },
        ClientId=globalConfig["UserPoolClient"],
    )
    result["user1UserIdToken"] = idp_response["AuthenticationResult"]["IdToken"]
    result["user1UserAccessToken"] = idp_response["AuthenticationResult"]["AccessToken"]
    result["user1UserRefreshToken"] = idp_response["AuthenticationResult"]["RefreshToken"]
    # create user2 user account
    sm_response = sm_client.get_random_password(ExcludeCharacters='"''`[]{}():;,$/\\<>|=&',
                                                RequireEachIncludedType=True)
    result["user2UserName"] = "user2User@example.com"
    result["user2UserPassword"] = sm_response["RandomPassword"]
    try:
        idp_client.admin_delete_user(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user2UserName"])
    except idp_client.exceptions.UserNotFoundException:
        print('User2 user haven''t been created previously')
    idp_response = idp_client.sign_up(
        ClientId=globalConfig["UserPoolClient"],
        Username=result["user2UserName"],
        Password=result["user2UserPassword"],
        UserAttributes=[{"Name": "name", "Value": result["user2UserName"]}]
    )
    result["user2UserSub"] = idp_response["UserSub"]
    idp_client.admin_confirm_sign_up(UserPoolId=globalConfig["UserPool"],
                                     Username=result["user2UserName"])
    
    # get new user2 user authentication info
    idp_response = idp_client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': result["user2UserName"],
            'PASSWORD': result["user2UserPassword"]
        },
        ClientId=globalConfig["UserPoolClient"],
    )
    result["user2UserIdToken"] = idp_response["AuthenticationResult"]["IdToken"]
    result["user2UserAccessToken"] = idp_response["AuthenticationResult"]["AccessToken"]
    result["user2UserRefreshToken"] = idp_response["AuthenticationResult"]["RefreshToken"]
    return result

def clear_dynamo_tables():
    LOGGER.info("Clearing DynamoDb tables")
    # clear all data from the tables that will be used for testing
    dbd_client = boto3.client('dynamodb')
    db_response = dbd_client.scan(
        TableName=globalConfig['Favourites_Table'],
        AttributesToGet=['user_id', 'restaurant_id']
    )
    for item in db_response["Items"]:
        dbd_client.delete_item(
            TableName=globalConfig['Favourites_Table'],
            Key={'user_id': {'S': item['user_id']["S"]}, 'restaurant_id': {'S': item['restaurant_id']["S"]}}
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