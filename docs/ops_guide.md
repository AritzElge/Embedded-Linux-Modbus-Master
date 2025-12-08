# Operations and Troubleshooting Guide

## System Health Monitoring
The ELI_galileo system provides physical and remote monitoring capabilities.

### Physical Monitoring (Status LED)
The onboard LED provides immediate system status feedback. This is the primary diagnostic tool in case of network or main display failure.

| LED State          | Status Description                                 | Action Required                                              |
|--------------------|----------------------------------------------------|--------------------------------------------------------------|
| 1 Hz Pulse         | SYSTEM HEALTHY. All daemons operational.           | None. System nominal.                                        |
| Solid ON/OFF       | System Halted or Kernel Panic/Unrecoverable Error. | Hard reboot required. Check serial console logs for details. |

### Error Code Indication (Long/Short Pulses)

| Pattern (Long-Short) | Status Description                                 | Troubleshooting Steps                                                                           |
|----------------------|----------------------------------------------------|-------------------------------------------------------------------------------------------------|
|    S-S-S-L           | LCD daemon error                                   | 1. SSH in, check systemctl status lcd-daemon. 2. Check physical SPI wiring (Hardware Schematic).|
|    S-S-L-S           | Polling daemon error                               | 1. SSH in, check systemctl status domotica-modbus-client. 2. Check network connectivity.        |
|    S-S-L-L           | Scheduling daemon error                            | 1.  SSH in, check systemctl status domotica-schedule-daemon. 2. Check Python dependencies.      |
|    L-S-L-S           | HDD Mount Failure                                  | 1. Check physical USB connection. 2. Verify HDD formatting (ext4). 3. Reboot system.            |
|    L-L-L-L           | Blink Daemon Internal Error                        | Monitoring system failure, forced reboot required                                               |

## Remote Troubleshooting via SSH
For detailed diagnostics, use SSH to access the system via the Management IP (configured in the Deployment Guide).

### Checking Daemon Status
Use systemctl commands to interact with individual services:
```
# Check status of the polling daemon
systemctl status domotica-polling-daemon

# Restart a failed daemon
systemctl restart domotica-polling-daemon
```

### Analyzing Logs
Logs are stored persistently on the external HDD in /mnt/hdd/logs/. Use standard Linux tools for analysis:
```
# View real-time logs for the modbus system
tail -f /mnt/hdd/logs/modbus.log

# Search for specific errors in system logs
grep "ERROR" /mnt/hdd/logs/system.log
```

### Disaster Recovery Procedures
In the event of an unrecoverable software error (e.g., kernel panic, system bricked during update), refer to the manual re-flashing procedure detailed in the Initial Deployment Guide.

## Maintenance and Obsolescence Management
This section outlines routine maintenance tasks and acknowledges the lifecycle status of the Intel Galileo Gen 2 platform.

### Routine Preventive Maintenance
*   **RTC Battery Check (Annual):** Verify the CR2032 battery voltage annually to ensure accurate timekeeping in isolated environments (see Hardware Details).
*   **Log Rotation/Archiving (Monthly):** Ensure log rotation scripts are functioning correctly to prevent the HDD from filling up. Archive critical logs off-site via a secure channel if possible.
*   **System Health Audit (Quarterly):** Perform a full functional test using the procedures defined in the Deployment Acceptance Testing Guide.

### Obsolescence Plan
The Intel Galileo Gen 2 and Quark X1000 SoC are discontinued products. This project relies on optimizing the longevity of existing hardware.
*   **Spares Management:** Maintain a stock of spare boards and components.
*   **Migration Strategy:** Refer to the Project Roadmap for future plans regarding migration to alternative platforms (e.g., Yocto, standard Linux APIs) to ensure long-term sustainability of the system architecture.
