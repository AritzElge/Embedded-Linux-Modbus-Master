"""
Utility script to calculate the next sleep duration for the daemon.sh script.
Outputs the number of seconds to sleep to stdout.
"""

import json
import datetime
import sys
import os
from filelock import FileLock 

# Mutex Configuration: Use the SAME lock file as device_controller.py
SCHEDULE_JSON_LOCK = "/tmp/schedule_app.lock" 
SCHEDULE_FILE = "schedule.json" 

def calculate_sleep_time():
    
    # --- MUTEX TO PROTECT THE READING ---
    with FileLock(SCHEDULE_JSON_LOCK):
        try:
            with open(SCHEDULE_FILE, 'r') as f:
                schedule_data = json.load(f)
        except (FileNotFoundError, json.JSONDecodeError) as e:
            print(3600) # Default to 1 hour if file is missing or corrupt
            sys.exit(0)

        now = datetime.datetime.now()
        # Initialize with a very large value (e.g., 24 hours in seconds)
        min_sleep_seconds = 24 * 3600 

        for entry in schedule_data:
            schedule_time = datetime.datetime.strptime(entry['start_time'], "%H:%M").time()
            next_time_target = datetime.datetime.combine(now.date(), schedule_time)
            
            # If the event already passed today, calculate for tomorrow
            if next_time_target <= now:
                next_time_target += datetime.timedelta(days=1)
            
            # Calculate the sleep time for THIS specific event
            current_event_sleep = (next_time_target - now).total_seconds()

            # Compare if this event is closer than the closest event we found so far.
            if current_event_sleep < min_sleep_seconds:
                min_sleep_seconds = current_event_sleep

        if min_sleep_seconds < 10:
            min_sleep_seconds = 10
            
        # Print the minimum value we found
        print(int(min_sleep_seconds))
    # The lock is automatically released here
    

if __name__ == "__main__":
    calculate_sleep_time()

