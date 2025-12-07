# Deployment Guide

## Pre-requiites
Before starting the deployment, ensure you have the following items and tools ready:

*   **Host PC:** Linux machine with Buildroot dependencies installed and the ability to run ./setup.sh scripts.
*   **Galileo Hardware:**
    *   Intel Galileo Gen 2 Board.
    *   MicroSD Card (minimum 4GB).
    *   External USB Hard Drive (HDD) for logs and daemons.
    *   Ethernet Cable.
    *   Modbus Modules and SPI LCD connected according to the Hardware Connection Schematic.
*   Tools: dd or Balena Etcher for flashing the image.

## Operating System Image Generation
This step is performed on the Host PC.
1. **Clone the Repository:**
```
git clone github.com
cd ELI_galileo
```
2. **Configure and Compile the Workspace:**
The ./setup.sh script automates the Buildroot process, generating the cross-toolchain and the final sdcard.img image in the output/images/ directory.
```
./setup.sh
```

##  Deployment to MicroSD Card and HDD
1. **Flash the Image:**
Use dd to write the generated image to the MicroSD card. CAUTION: Make sure you select the correct device (/dev/sdx).
```
sudo dd if=output/images/sdcard.img of=/dev/sdx bs=4M status=progress
```

2. **Prepare the External HDD:**
The system expects the USB HDD to be formatted and ready to mount the logs and daemons partitions upon boot.

## Network Configuration (Isolation Strategy)
The system is designed to operate on an isolated LAN with a defense-in-depth strategy:
1. **Physical Connection:** Connect the Galileo Gen 2 to your router/switch using Ethernet.
2. **DHCP vs. Static IP:** The system is configured to obtain an IP address via DHCP initially. It is strongly recommended to configure a static IP on your router or on the Galileo itself once deployed.
3. **Secure SSH Access:**
    1. Root access via password is disabled.
    2. Access is granted only via SSH public/private key authentication.
    3. Ensure your public key is copied to the device after the first boot.
4. **Firewall Configuration (`iptables`):**
The system boots with pre-configured iptables rules to block all traffic except:
    1. Necessary traffic for Modbus TCP/IP (Port 5020, configurable).
    2. SSH access (Port 22) from the specified management IP.
    3. **Operator Action:** Verify that `iptables` rules are applied correctly on boot and adjust the Modbus port if necessary in `/etc/iptables/rules.v4`.
5. **Static ARP Tables:**
To mitigate ARP poisoning attacks, configure static ARP tables on the Galileo Gen 2.
    1. **Operator Action:** Edit the network configuration script to add static entries for all Modbus devices on the isolated network.

## First Boot and Verification
1. Insert the MicroSD card and connect the USB HDD to the Galileo.
2. Power on the board.
3. Observe the status LED: it should show the 1Hz heartbeat (healthy system) after a few minutes.
4. Access via SSH using your private key to verify the logs in /mnt/hdd/logs/.

## Deployment Acceptance Testing and V&V (Verification & Validation)
Upon successful initial boot, the following procedures must be executed via SSH to formally verify system integrity and operational readiness.
1. **System Health Checks**
*   **Verify Heartbeat:** Physically confirm the onboard LED is blinking at the standard 1Hz rate. If specific error codes are displayed, consult the Operations Guide.
*   **Verify Daemons Status:** Log in via SSH and confirm all expected services are active:
```
systemctl status domotica-schedule-daemon
systemctl status domotica-polling-daemon
systemctl status lcd-daemon
# Verify other daemons...
```
2. **Data Integrity and Logging Verification**
*   **Confirm HDD Mount:** Ensure the external HDD is correctly mounted and available:
```
mountpoint /mnt/hdd
```
*   **Verify Timestamps:** Check the system time and a log file entry to confirm accurate RTC synchronization:
```
date
tail -n 1 /mnt/hdd/logs/system.log
```
3. **Hardware Interface Testing**
*   **SPI LCD Test:**
    *   **Procedure:** Execute a test script to display a predefined message (e.g., "V&V Pass") on the LCD screen.
    *   **Expected Result:** The message appears correctly on the SPI LCD.
*   **Modbus Communication Test:**
    *   **Procedure:** Use a command-line utility or Python test script to poll a known sensor value from one of the Modbus devices.
    *   **Expected Result:** A valid data reading is returned (e.g., temperature value) and logged without errors in /mnt/hdd/logs/modbus.log.

4. **Network Security Verification**
*   **Firewall Test (Principle of Least Privilege):**
    *   **Procedure:** From a different host on the network (one not specified in the iptables allow rules), attempt to SSH into the Galileo board or connect to the Modbus port.
    *   **Expected Result:** The connection attempts are actively refused by the Galileo`s firewall.
*   **ARP Table Verification:**
    *   **Procedure:** Log in via SSH and inspect the active ARP table to ensure entries are static as configured:
    *   **Expected Result:** The output confirms static entries for critical Modbus IPs.