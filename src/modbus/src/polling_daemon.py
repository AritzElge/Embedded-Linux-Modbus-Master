"""
Modbus Polling Daemon

Reads device configurations from 'sensors.json' and performs a single Modbus TCP
polling cycle. Uses a JSON-specific filelock, then calls the hardware client which
manages the hardware lock internally.

Functions:
    run_polling_daemon: Main execution function to coordinate polling.

Dependencies:
    modbus_client: Provides Modbus communication functions.
    sensors.json: Configuration file with device details.
...
"""

import os
import json
from filelock import FileLock
from modbus_client import get_sensor_reg

# Mutex to protect the sensors.json file
SENSORS_JSON_LOCK = "/tmp/sensors_app.lock"
SENSORS_FILE = "sensors.json"

def run_polling_daemon():
    """
    Main daemon function to execute a single polling cycle of Modbus devices.

    This function coordinates the following steps:
    1. Acquires a filelock specific to the 'slaves.json' file.
    2. Reads the device configurations into memory.
    3. Releases the filelock immediately after reading.
    4. Iterates through the loaded configurations and calls the Modbus client
       function for each sensor (which handles the hardware-level mutex internally).
    """

    devices = []

    # --- 1. LOCK, READ JSON, AND RELEASE JSON MUTEX ---
    with FileLock(SENSORS_JSON_LOCK):
        print(f"Process {os.getpid()}: JSON Mutex acquired for reading sensors.json.")
        with open(SENSORS_FILE, "r", encoding='utf-8') as f:
            devices = json.load(f)
        print(f"Process {os.getpid()}: JSON Mutex released.")

    # --- 2. USE THE LOADED DATA (OUTSIDE THE JSON MUTEX) ---
    # Process each device. The function called internally uses the hardware mutex.
    for device in devices:
        if device.get("type") == "sensor":
            print(f"Calling get_sensor_reg for {device['label']} "
            f("(will use hardware mutex internally)...")
            get_sensor_reg(device["label"], device["ip"], device["port"], device["length"])

if __name__ == "__main__":
    run_polling_daemon()
