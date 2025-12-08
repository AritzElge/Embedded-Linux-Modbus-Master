"""
Modbus TCP Client Module

Provides functions to communicate with Modbus TCP slave devices for
industrial and embedded applications. Includes support for reading
sensor data (function 0x03) and writing to actuators (function 0x06).

Functions:
    get_sensor_reg: Read holding registers from a sensor.
    set_actuator_reg: Write a single register to control an actuator.

Dependencies:
    pymodbus: Must be installed (compatible with v1.5+ for legacy systems).

Note:
    Designed for use with polling_daemon.py and slaves.json configuration.
"""

from datetime import datetime
from filelock import FileLock
from pymodbus.client.sync import ModbusTcpClient

MODBUS_CLIENT_MUTEX = "/tmp/modbus_client.lock"

def get_sensor_reg(slave_label, slave_ip, coms_port, data_length):
    """
    Read holding registers from a Modbus TCP sensor.

    Performs a Modbus function 0x03 (Read Holding Registers) request to retrieve
    sensor data from a remote device.

    Args:
        slave_label (str): Human-readable name for the sensor.
        slave_ip (str): IP address of the Modbus slave device.
        coms_port (int): TCP port number (typically 502 or 5020).
        data_length (int): Number of contiguous registers to read.

    Returns:
        list/int: Prints register retrieved if successful, otherwise returns None.
    """
    with FileLock(MODBUS_CLIENT_MUTEX):
        client = ModbusTcpClient(slave_ip, port=coms_port)
        try:
            if not client.connect():
                print(f"Connection failed to {slave_ip}:{coms_port}")
                return None

            result = client.read_holding_registers(address=0, count=data_length, slave=1)
            if not result.isError():
                print(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} : {slave_label} : "
                      f"{slave_ip} : {coms_port} : {result.registers}")
                return result.registers

            print(f"Error for {slave_label}: {result}")
            return None
        finally:
            # Ensures the client always closes, even if an error occurs above
            client.close()


def set_actuator_reg(actuator_label, actuator_ip, coms_port, register_address, value):
    """
    Write a value to a single register of a Modbus TCP actuator.

    Performs a Modbus function 0x06 (Write Single Register) request to control
    an actuator.

    Args:
        actuator_label (str): Human-readable name for the actuator.
        actuator_ip (str): IP address of the Modbus slave device.
        coms_port (int): TCP port number.
        register_address (int): Target register address (0-65535).
        value (int): Value to write (0-65535).

    Returns:
        bool: True if successful, otherwise False.
    """
    with FileLock(MODBUS_CLIENT_MUTEX):
        client = ModbusTcpClient(actuator_ip, port=coms_port)
        try:
            if not client.connect():
                print(f"Connection failed to {actuator_ip}:{coms_port}")
                return False

            result = client.write_register(address=register_address, value=value, device_id=1)
            if not result.isError():
                print(f"{datetime.now().strftime('%Y-%m-%d %H:%M:%S')} : {actuator_label} : "
                      f"{actuator_ip} : {coms_port} : SET {register_address} = {value}")
                return True

            # R1705 Fix: No 'else' needed after a 'return'
            print(f"Error for {actuator_label}: {result}")
            return False
        finally:
            client.close()
