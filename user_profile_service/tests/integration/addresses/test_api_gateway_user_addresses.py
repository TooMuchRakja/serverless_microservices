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
    # LOGGER.info("ID token: %s", global_config["user1UserIdToken"]) ##
    # LOGGER.info("Endpoint: %s", global_config["address_api_endpoint_url"])
    invalid_address = {"city": "Seattle", "stateProvince": "WA", "postal": "12345"}
    response = requests.post(
        global_config["address_api_endpoint_url"] + '/address',
        data=json.dumps(invalid_address),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    ) 
    assert response.status_code == 500
   
def test_add_user_address(global_config):
    # Add an address
    requests.post(
        global_config["address_api_endpoint_url"] + '/address',
        data=json.dumps(user1_new_address),
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )

    # Check the number of addresses
    check_response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )
    addresses = json.loads(check_response.text).get("addresses", [])
    assert len(addresses) == 1, f"Expected 1 address, found {len(addresses)}"

def test_update_user_address(global_config):
    # Get the address to update
    get_response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )
    user1addresses = json.loads(get_response.text)
    address_id = user1addresses['addresses'][0]['address_id']

    # Data for update
    updated_address_info = {
        "line1": "4566 Main",
        "line2": "Suite 200",
        "city": "Seattle",
        "stateProvince": "WA",
        "postal": "12345"
    }

    # Perform the update
    requests.put(
        global_config["address_api_endpoint_url"] + f'/address/{address_id}',
        data=json.dumps(updated_address_info),
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )

    # Fetch the address again and compare with expected data
    verify_response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )
    updated_data = json.loads(verify_response.text)['addresses'][0]

    for key, value in updated_address_info.items():
        assert updated_data.get(key) == value, f"Field '{key}' mismatch: expected '{value}', got '{updated_data.get(key)}'"


def test_delete_user_address(global_config):
    # Get the address to delete
    get_response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )
    addresses = json.loads(get_response.text).get("addresses", [])
    assert addresses, "No addresses found to delete"

    address_id = addresses[0]['address_id']

    # Delete the address
    requests.delete(
        global_config["address_api_endpoint_url"] + f'/address/{address_id}',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )

    # Verify that the address list is now empty
    verify_response = requests.get(
        global_config["address_api_endpoint_url"] + '/address',
        headers={
            'Authorization': global_config["user1UserIdToken"],
            'Content-Type': 'application/json'
        }
    )
    remaining_addresses = json.loads(verify_response.text).get("addresses", [])
    assert len(remaining_addresses) == 0, f"Expected 0 addresses, found {len(remaining_addresses)}"
