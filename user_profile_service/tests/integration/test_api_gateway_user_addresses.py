import json
import requests
import logging
import time
import uuid
import copy

LOGGER = logging.getLogger(__name__)

user1_new_address = {"line1": "4566 Main", "line2": "Suite 200", "city": "Seattle", "stateProvince": "WA", "postal": "12345"}
user2_new_address = {"line1": "7505 Beverly Blvd", "line2": "Apt 7", "city": "Los Angeles", "stateProvince": "CA", "postal": "90036"}

def test_add_user_address_with_invalid_fields(global_config):
    # LOGGER.info("ID token: %s", global_config["user1UserIdToken"])
    # LOGGER.info("Endpoint: %s", global_config["address_api_endpoint_url"])
    invalid_address = {"city": "Seattle", "stateProvince": "WA", "postal": "12345"}
    response = requests.post(
        global_config["address_api_endpoint_url"] + '/address',
        data=json.dumps(invalid_address),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    ) 
    assert response.status_code == 400
    
def test_add_user_address(global_config):
    # LOGGER.info("ID token: %s", global_config["user1UserIdToken"])
    # LOGGER.info("Endpoint: %s", global_config["address_api_endpoint_url"])
    response = requests.post(
        global_config["address_api_endpoint_url"] + '/address',
        data=json.dumps(user1_new_address),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    ) 
    assert response.status_code == 200  

def test_update_user_address(global_config):
    # LOGGER.info("ID token: %s", global_config["user1UserIdToken"])
    # LOGGER.info("Endpoint: %s", global_config["address_api_endpoint_url"])
    user1response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    )

    # LOGGER.info(user1response.text)
    user1addresses = json.loads(user1response.text) 
    updated_address_info = {"line1": "4566 Main", "line2": "Suite 200", "city": "Seattle", "stateProvince": "WA", "postal": "12345"} 

    response = requests.put(
        global_config["address_api_endpoint_url"] + '/address/' + user1addresses['addresses'][0]['address_id'],
        data=json.dumps(updated_address_info),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}        
    )
    assert response.status_code == 200  

def test_delete_user_address(global_config):

    user1response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    )

    # LOGGER.info(user1response.text)
    user1addresses = json.loads(user1response.text)  

    response = requests.delete(
        global_config["address_api_endpoint_url"] + '/address/' + user1addresses['addresses'][0]['address_id'],
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}        
    )
    assert response.status_code == 200