import unittest
from unittest.mock import patch, mock_open, MagicMock
import os
import sys
import json

# --- Adjust Python Path to find the source code ---
scripts_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src', 'modbus', 'src'))
if scripts_path not in sys.path:
    sys.path.append(scripts_path)
# --------------------------------------------------

import polling_daemon 

class TestPollingDaemon(unittest.TestCase):

    @patch('polling_daemon.get_sensor_reg')
    @patch('polling_daemon.FileLock')
    def test_run_polling_daemon_success(self, MockFileLock, mock_get_sensor_reg):
        """
        Test case for a successful run of the daemon.
        """
        
        # 1. Setup Mocks -------------------------------------
        mock_get_sensor_reg.return_value = 42
        mock_devices_json_data = json.dumps([
            {"label": "TempSensor1", "ip": "192.168.1.100", "port": 502, "length": 1, "type": "sensor"}
        ])

        mock_json_file_handle = mock_open(read_data=mock_devices_json_data)()
        mock_csv_file_handle = mock_open()() 

        def open_side_effect(file_path, *args, **kwargs):
            if file_path == polling_daemon.SENSORS_FILE:
                return mock_json_file_handle
            return mock_csv_file_handle

        with patch('os.path.exists', return_value=False):
            with patch('os.stat') as mock_os_stat:
                mock_os_stat.return_value.st_size = 0
                with patch('builtins.open', side_effect=open_side_effect) as mock_open_func:

                    # 2. Execute the function ----------------------------------
                    polling_daemon.run_polling_daemon()

                    # 3. Assertions (Verifications) ----------------------------
                    mock_get_sensor_reg.assert_called_once_with('TempSensor1', '192.168.1.100', 502, 1)
                    mock_open_func.assert_called_with(polling_daemon.TMP_CSV_FILE_PATH, mode='a', newline='', encoding='utf-8')

                    # Extract the actual string written to the mock file
                    # call_args.args[0] gets the first positional argument of the 'write' call
                    actual_written_string = mock_csv_file_handle.write.call_args.args[0]

                    # Verify that specific strings are present in the written data
                    self.assertIn('42', actual_written_string)
                    self.assertIn('TempSensor1', actual_written_string)


    @patch('polling_daemon.FileLock')
    def test_run_polling_daemon_file_not_found(self, MockFileLock):
        """
        Test case where the sensors.json config file is missing.
        """
        with patch('builtins.open', side_effect=FileNotFoundError):
            polling_daemon.run_polling_daemon()


if __name__ == '__main__':
    unittest.main()
