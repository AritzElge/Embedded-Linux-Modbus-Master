"""
Main daemon script for polling Modbus TCP sensors.

This script reads configuration from a JSON file, polls sensor data via Modbus, 
and logs the results to a CSV file (on HDD or /tmp fallback).
It uses file locks to manage concurrent access to resources.
"""

import os
import sys  # Import sys here to resolve E0602 error if needed for sys.stderr
import json
import csv  # Standard Python library
import time
# Get the absolute path of the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Add this directory to Python's module search path (sys.path)
if script_dir not in sys.path:
    sys.path.append(script_dir)

from filelock import FileLock
from modbus_client import get_sensor_reg # Assumed to return data
# -----------------------------------------------------------

# Mutex to protect the sensors.json file
SENSORS_JSON_LOCK = "/tmp/sensors_app.lock"
SENSORS_FILE = "/usr/bin/sensors.json"

# Define the primary location for the CSV file (on the HDD)
CSV_FILE_PATH = "/mnt/hdd/logs/sensor_readings.csv"
# Define the fallback location (in RAM)
TMP_CSV_FILE_PATH = "/tmp/sensor_readings.csv"


def run_polling_daemon():
    """
    Main daemon function to execute a single polling cycle of Modbus devices.
    """

    devices = []

    # --- 1. LOCK, READ JSON, AND RELEASE JSON MUTEX ---
    with FileLock(SENSORS_JSON_LOCK):
        print(f"Process {os.getpid()}: JSON Mutex acquired for reading {SENSORS_FILE}.")
        try:
            # Add encoding='utf-8' for W1514 fix
            with open(SENSORS_FILE, "r", encoding='utf-8') as f:
                devices = json.load(f)
            print(f"Read {len(devices)} devices from JSON configuration.")
        except FileNotFoundError:
            # Use sys.stderr instead of os.sys.stderr
            print(f"ERROR: Configuration file {SENSORS_FILE} not found.", file=sys.stderr)
            return
        except json.JSONDecodeError:
            # Use sys.stderr instead of os.sys.stderr
            print(f"ERROR: Failed to decode JSON from {SENSORS_FILE}", file=sys.stderr)
            return

        print(f"Process {os.getpid()}: JSON Mutex released.")

    # --- 2. PREPARE THE CSV FILE AND COLLECT DATA ---
    # Determine which file path to use (HDD or RAM) based on whether the log directory exists
    # This complements the Bash script's logic
    target_csv = CSV_FILE_PATH if os.path.exists(
        os.path.dirname(CSV_FILE_PATH)) else TMP_CSV_FILE_PATH # C0301 fix

    # Define the CSV headers (adjust these field names to match your data structure)
    fieldnames = ['timestamp', 'label', 'ip', 'port', 'length', 'value']

    # Open the file in 'a' (append) mode. It creates the file if it doesn't exist.
    # Add encoding='utf-8' for W1514 fix
    with open(target_csv, mode='a', newline='', encoding='utf-8') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)

        # Write the header only if the file is empty (only at creation time)
        if os.stat(target_csv).st_size == 0:
            writer.writeheader()

        # Iterate through devices and write data
        for device in devices:
            if device.get("type") == "sensor":
                print(f"Calling get_sensor_reg for {device['label']} "
                      f"(will use hardware mutex internally)...") # C0301 fix

                # CAPTURE the data returned by the Modbus client
                sensor_data = get_sensor_reg(device["label"], device["ip"],
                                             device["port"], device["length"]) # C0301 fix

                if sensor_data is not None:
                    # Create a dictionary for the CSV row (C0301 fix below)
                    row = {
                        'timestamp': time.strftime("%Y-%m-%d %H:%M:%S"),
                        'label': device['label'],
                        'ip': device['ip'],
                        'port': device['port'],
                        'length': device['length'],
                        'value': sensor_data 
                    }
                    writer.writerow(row)
                    print(f"Data logged to CSV for {device['label']}.")
                else:
                    print(f"WARNING: Could not retrieve data for {device['label']}. "
                          f"get_sensor_reg returned None.") # C0301 fix

if __name__ == "__main__":
    run_polling_daemon()
