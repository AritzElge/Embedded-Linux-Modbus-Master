#!/usr/bin/env python3
"""
Utility script to calculate the next sleep duration for the daemon.sh script.
Outputs the number of seconds to sleep to stdout.
"""

import os
import sys
import json
import datetime

# Get the absolute path of the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Add this directory to Python's module search path (sys.path)
if script_dir not in sys.path:
    sys.path.append(script_dir)

from filelock import FileLock
# -----------------------------------------------------------

SCHEDULE_JSON_LOCK = "/tmp/schedule_app.lock"
SCHEDULE_FILE = "/mnt/hdd/daemons/modbus/schedule.json"

def calculate_sleep_time():
    """
    Utility script to calculate the next sleep duration fo the daemon.sh
    Outputs the number of seconds to sleep to stdout
    """
    # --- MUTEX TO PROTECT THE READING ---
    with FileLock(SCHEDULE_JSON_LOCK):
        try:
            with open(SCHEDULE_FILE, 'r', encoding='utf-8') as f:
                schedule_data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as err:
            print(f"Error reading schedule file: {err}", file=sys.stderr)
            print(3600)
            sys.exit(0)

        # Logic to find the closest event in the future
        now = datetime.datetime.now()
        min_sleep_seconds = 24 * 3600 # Initialize with 24 hours

        for entry in schedule_data:
            # Basic protection if 'start_time' key is missing in an entry
            start_time_str = entry.get('start_time')
            if not start_time_str:
                continue

            schedule_time = datetime.datetime.strptime(start_time_str, "%H:%M").time()
            next_time_target = datetime.datetime.combine(now.date(), schedule_time)

            # If the event already passed today, calculate for tomorrow
            if next_time_target <= now:
                next_time_target += datetime.timedelta(days=1)

            # Calculate the sleep time for THIS specific event
            current_event_sleep = (next_time_target - now).total_seconds()
            min_sleep_seconds = min(min_sleep_seconds, current_event_sleep)

        # Ensure minimum sleep time of 10 seconds using max()
        min_sleep_seconds = max(min_sleep_seconds, 10)

        print(int(min_sleep_seconds))


if __name__ == "__main__":
    """Main execution point for the sleep time calculator."""
    calculate_sleep_time()
