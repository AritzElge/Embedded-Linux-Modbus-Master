"""
Device Controller Script.

Reads schedule.json, determines the state, and sends an order.
Uses a JSON-specific filelock, then calls the hardware client which
manages the hardware lock internally.
...
"""

import os
import json
import datetime
# Get the absolute path of the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Add this directory to Python's module search path (sys.path)
if script_dir not in sys.path:
    sys.path.append(script_dir)

from modbus_client import set_actuator_reg
from filelock import FileLock

# Mutex to protect the schedule.json file
SCHEDULE_JSON_LOCK = "/tmp/schedule_app.lock"
SCHEDULE_FILE = "/mnt/hdd/daemons/modbus/schedule.json"

def read_and_execute_scheduled_events_with_window():
    """
    Reads the schedule.json file, determines which events should have run
    in the last minute (current minute and previous minute), and sends
    corresponding orders via the hardware client

    Uses a filelock for json file access and assumes the hardware client
    manages its own internal hardware lock.
    """
    entries_to_execute = []

    # --- 1. lock, read json, and release json mutex ---
    with FileLock(SCHEDULE_JSON_LOCK):
        print(f"process {os.getpid()}: json mutex acquired for reading schedule.")
        try:
            with open(SCHEDULE_FILE, 'r', encoding='utf-8') as f:
                schedule_data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(f"Error reading schedule file: {e}")
            return

        # Determine the current time and the time one minute ago
        now = datetime.datetime.now()
        one_minute_ago = now - datetime.timedelta(minutes=1)

        # Define the acceptable time window: from one minute ago up to 'now'
        target_minutes = {
            (now.hour, now.minute),
            (one_minute_ago.hour, one_minute_ago.minute)
        }

        for entry in schedule_data:
            scheduled_time_obj = datetime.datetime.strptime(entry['start_time'], "%H:%M").time()
            scheduled_hour_minute = (scheduled_time_obj.hour, scheduled_time_obj.minute)

            if scheduled_hour_minute in target_minutes:
                entries_to_execute.append(entry)

        print(f"process {os.getpid()}: json mutex released.")

    # --- 2. Execute the found events (outside the json mutex) ---
    if entries_to_execute:
        print(f"Found {len(entries_to_execute)} events scheduled within the last minute window.")
        for entry in entries_to_execute:
            set_actuator_reg(
                entry["label"],
                entry["ip"],
                entry["port"],
                entry["register_address"],
                entry["valor"]
            )
    else:
        print("No events found scheduled within the last minute window.")

if __name__ == "__main__":
    if not os.path.exists(SCHEDULE_FILE):
        print(f"Error: The schedule file '{SCHEDULE_FILE}' was not found.")
    else:
        read_and_execute_scheduled_events_with_window()
