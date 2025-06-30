
import json
import requests
import logging
import time
import uuid

LOGGER = logging.getLogger(__name__)

user1_new_favorite = {"restaurantId": str(uuid.uuid4())}
user2_new_favorite = {"restaurantId": str(uuid.uuid4())}

def test_access_to_the_favorites_without_authentication(global_config):
    response = requests.get(global_config["address_api_endpoint_url"] + '/favourites')
    assert response.status_code == 401  

def test_add_user_favorite(global_config):
    # LOGGER.info("ID token: %s", global_config["user1UserIdToken"])
    # LOGGER.info("Endpoint: %s", global_config["address_api_endpoint_url"])
    response = requests.post(
        global_config["address_api_endpoint_url"] + '/favourites',
        data=json.dumps(user1_new_favorite),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    ) 
    LOGGER.info(response)
    assert response.status_code == 200  

    # ensure the async request in the queue has time to be processed
    time.sleep(1)

    response = requests.get(
        global_config["address_api_endpoint_url"] + '/favourites',
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    )
    assert response.status_code == 200

    response_data = json.loads(response.text)
    # LOGGER.info(response.text)
    assert len(response_data['favorites']) == 1
    assert response_data['favorites'][0]['restaurant_id'] == user1_new_favorite['restaurantId']

def test_delete_user_favorite(global_config):
    response = requests.post(
        global_config["address_api_endpoint_url"] + '/favourites',
        data=json.dumps(user1_new_favorite),
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    ) 
    assert response.status_code == 200  

    # ensure the async request in the queue has time to be processed
    time.sleep(1)

    response = requests.delete(
        global_config["address_api_endpoint_url"] + '/favourites/' + user1_new_favorite['restaurantId'],
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}        
    )
    assert response.status_code == 200

    # ensure the async request in the queue has time to be processed
    time.sleep(1)    

    response = requests.get(
        global_config["address_api_endpoint_url"] + '/favourites',
        headers={'Authorization': global_config["user1UserIdToken"], 
            'Content-Type': 'application/json'}
    )
    assert response.status_code == 200

    response_data = json.loads(response.text)
    assert len(response_data['favorites']) == 0
