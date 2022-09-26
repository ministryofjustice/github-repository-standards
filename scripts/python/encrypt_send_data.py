""" Encrypts data and sends it to the Standards Report website """
import json
import os
import requests
from cryptography.fernet import Fernet


def encrypt_json(plain_data):
    """encrypt provided data

    Args:
        plain_data (): plain text data

    Returns:
        string: encrypted data
    """
    key_hex = os.getenv("ENCRYPTION_KEY")
    key = bytes.fromhex(key_hex)
    fernet = Fernet(key)
    data_as_string = json.dumps(plain_data)
    data_as_bytes = data_as_string.encode()
    encrypted_data_as_bytes = fernet.encrypt(data_as_bytes)
    encrypted_data_bytes_as_string = encrypted_data_as_bytes.decode()
    return encrypted_data_bytes_as_string


def get_data_from_file(filename):
    """Get json data from a file
    Returns:
        list: json data
    """
    data = []
    with open(filename, "r") as f:
        data = json.load(f)
    return data


def send_encrypted_data_to_server():
    """Encrypt and send data to the website"""

    headers = {
        "Content-Type": "application/json",
        "X-API-KEY": os.getenv("OPERATIONS_ENGINEERING_REPORTS_API_KEY"),
    }

    if os.path.exists("public_data.json"):
        url = (
            os.getenv("OPERATIONS_ENGINEERING_REPORTS_HOST")
            + "/update_public_repositories"
        )
        json_data = get_data_from_file("public_data.json")
        encrypted_data = encrypt_json(json_data)
        req = requests.post(url, headers=headers,
                            json=encrypted_data, timeout=3)
        if req.status_code == 200:
            print("Sent public data to site")

    if os.path.exists("private_data.json"):
        url = (
            os.getenv("OPERATIONS_ENGINEERING_REPORTS_HOST")
            + "/update_private_repositories"
        )
        json_data = get_data_from_file("private_data.json")
        encrypted_data = encrypt_json(json_data)
        req = requests.post(url, headers=headers,
                            json=encrypted_data, timeout=3)
        if req.status_code == 200:
            print("Sent private data to site")


def main():
    """
    Main function
    """
    print("Start")
    send_encrypted_data_to_server()
    print("Finished")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # pylint: disable=broad-except
        print(f"help_code.py: Something went wrong. Here's what: {e}")
