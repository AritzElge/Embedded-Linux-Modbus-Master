import unittest
from unittest.mock import patch, mock_open, MagicMock
import os
import sys
import json
import datetime
from freezegun import freeze_time # <-- Import freezegun

# --- Adjust Python Path to find the source code ---
scripts_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src', 'modbus', 'src'))
if scripts_path not in sys.path:
    sys.path.append(scripts_path)
# --------------------------------------------------

# Import the main script module
import schedule_daemon 

class TestScheduleDaemon(unittest.TestCase):

    @patch('schedule_daemon.set_actuator_reg')
    @patch('schedule_daemon.FileLock')
    @freeze_time("2025-12-10 10:30:15") # <-- Freeze time to 10:30 AM
    def test_read_and_execute_within_window(self, MockFileLock, mock_set_actuator_reg):
        """
        Test case for successful execution of events within the 1-minute window.
        Time is frozen to ensure consistent testing of the 10:30 and 10:29 events.
        """
        
        # 1. Setup Mocks -------------------------------------
        # The script's datetime.datetime.now() will now return 2025-12-10 10:30:15

        mock_schedule_json_data = json.dumps([
            {"label": "Light1", "ip": "192.168.1.200", "port": 502, "register_address": 10, "value": 1, "start_time": "10:30"}, # Should execute
            {"label": "Light2", "ip": "192.168.1.201", "port": 502, "register_address": 10, "value": 0, "start_time": "10:29"}, # Should execute (1 min ago)
            {"label": "Heater", "ip": "192.168.1.202", "port": 502, "register_address": 10, "value": 1, "start_time": "10:00"}  # Should NOT execute (too early)
        ])
        
        mock_json_file_handle = mock_open(read_data=mock_schedule_json_data)() 

        def open_side_effect(file_path, *args, **kwargs):
            if file_path == schedule_daemon.SCHEDULE_FILE:
                return mock_json_file_handle
            return mock_open()()

        # Patch os.path.exists to confirm the schedule file is found
        with patch('os.path.exists', return_value=True):
            # Patch builtins.open with our custom side_effect
            with patch('builtins.open', side_effect=open_side_effect) as mock_open_func:

                # 2. Execute the function ----------------------------------
                schedule_daemon.read_and_execute_scheduled_events_with_window()

                # 3. Assertions (Verifications) ----------------------------

                # Verify that set_actuator_reg was called TWICE (for 10:30 and 10:29 events)
                self.assertEqual(mock_set_actuator_reg.call_count, 2)

                # Verify the calls were made
                mock_set_actuator_reg.assert_any_call('Light1', '192.168.1.200', 502, 10, 1)
                mock_set_actuator_reg.assert_any_call('Light2', '192.168.1.201', 502, 10, 0)


    @patch('schedule_daemon.FileLock')
    @patch('os.path.exists', return_value=False)
    def test_run_schedule_file_not_found(self, mock_exists, MockFileLock):
        """
        Test case where the schedule.json config file is missing.
        """
        with patch('builtins.open', side_effect=FileNotFoundError):
            result = schedule_daemon.read_and_execute_scheduled_events_with_window()
            self.assertIsNone(result)
            

if __name__ == '__main__':
    unittest.main()
