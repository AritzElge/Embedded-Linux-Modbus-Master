# Embedded Linux Integration with Intel Galileo Gen 2 (or ELI_galileo)

![Project Status](https://img.shields.io/badge/Project Status-WIP)
[![Static Analysis](https://github.com/AritzElge/ELI_galileo/actions/workflows/static_analysis.yml/badge.svg)](https://github.com/AritzElge/ELI_galileo/actions/workflows/static_analysis.yml)

This repository presents a master home automation control system designed to operate on an Intel Galileo Gen 2, utilizing MODBUS TCP/IP for managing smart sensors and actuators within the local network.

This project was selected as a technical challenge due to the platform's discontinued status and lack of official support, optimizing the system for the longevity and reliability of the available hardware.

---

## Table of Contents
- [Key Features](#key-features)
- [Hardware Used](#hardware-used)
- [System Requirements](#system-requirements)
- [Technical Features](#technical-features)
- [Software Architecture](#software-architecture)
- [Key Engineering Decisions](#key-engineering-decisions)
- [Setup Steps](#setup-steps)
- [Usage and Functionality](#usage-and-functionality)
- [System Updates](#system-updates)
- [Roadmap](#roadmap)
- [Acknowledgements](#Acknowledgements)
- [Contributing](CONTRIBUTING.md)
- [License](LICENSE)
- [Contact](#Contact)

---    

## Key Features

*   **MODBUS TCP/IP Management:** Full communication and control of smart devices (sensors and actuators) over the local network.
*   **SPI Interface:** Control of an LCD screen for local system status and error visualization.
*   **Data Persistence:** Use of an external USB-HDD to store daemons and logs, mitigating the degradation of the OS microSD card.
*   **Secure Updates:** *In-situ* update mechanism via a USB pendrive and `dpkg` package management with version verification.
*   **Visual Diagnostics:** Status LED for error code indication.
*   **Static ARP-Table:** for protection agains ARP-Poisoning. 

## Hardware Used

*   **Mainboard:** Intel Galileo Gen 2 (with CR2032 battery for RTC)
*   **Storage:** MicroSD card (OS) and external USB-HDD (Daemons/Logs)
*   **Interfaces:** LCD Screen (via SPI), Status LED, miniPCIExpress USB port expander, native Host-USB Port.
*   **Network:** Ethernet connection for MODBUS TCP/IP.

## System Requirements
*   Host PC with Linux (for cross-compilation) and 'python2' compatibility.
*   Intel Galileo Gen 2 board.

## Technical Features

*   **Master Platform:** Intel Galileo Gen 2 (Quark SoC X1000, Linux).
*   **Languages Used:** Ash shell, Python 3, Native C, Modern C++.
*   **Communication Protocol:** Modbus TCP/IP.
*   **Hardware Interfaces:** SPI (for LCD), GPIO (for multiplexer and LED control), Ethernet (for Modbus communication).
*   **Methodology:** Use of native POSIX APIs, BSD, Sockets, libmodbus, pthreads, and POSIX shared memory (IPC).
*   **Build System Tool:** **Buildroot** (used to generate the toolchain and the final Linux image).
*   **Coding Standards and Safety:** Adoption of the **MISRA C:2012 coding standard** (enforced via **CppCheck** static analysis) for all critical C/C++ daemons. This ensures compliance with safety guidelines required in high-integrity environments, minimizing common vulnerabilities like buffer overflows and undefined behavior.
*   Full automation of the Continuous Integration (CI) using **GitHub Actions**.

## Software Architecture

* **Modular Architecture:** Application software is decoupled from the base operating system.
* **Package Management:** Daemons are packaged as standard `.deb` packages that facilitate dependency management and incremental updates.

The system consists of several daemons that communicate internally:

*   `modbus_daemon` (C/C++): Manages network communication.
*   `lcd_daemon` (C/C++): Controls the SPI display and shows system status.
*   `status_manager` (C/C++): Uses POSIX shared memory (`shm_open`, `mmap`) for efficient IPC between daemons.

## Key Engineering Decisions

*   **Hybrid CI/CD Strategy:** Decision not to compile the entire Buildroot image in the cloud due to the performance and time limitations of public CI/CD runners. Instead, the validation (MISRA, unit tests) and packaging of the application software are prioritized.
*   **Reproducibility of the Buildroot: Use of bash scripts and `defconfig` files to automate the complete configuration of the Buildroot workspace, ensuring reproducible builds locally without manual intervention.
*   **Optimal Language Selection (Multi-Level Approach):** Decision to select the most suitable language for each task based on criticality and required performance. 
    *   **C/C++:** Used for performance-critical daemons (Modbus comms, SPI control) leveraging POSIX APIs for direct control.
    *   **Python:** Used for complex logic tasks where development speed is key.
    *   **Ash Shell/Bash:** Used exclusively for system initialization, setup scripts, and wrapper execution.
*   **Resource Management (RAII):** Use of modern C++ and the RAII pattern for safe and automatic management of file descriptors and shared memory.
*   **Timekeeping and Data Integrity:** Integration of a **CR2032 battery backup** for the Real-Time Clock (RTC) on the Galileo Gen 2 board. This ensures accurate timestamping of all system logs and events, which is critical for debugging, security auditing, and reliable data correlation in an isolated environment without constant NTP synchronization.
*   **Network Security:** 
    *   **Secure Access:** SSH access is restricted to public/private key authentication only, disabling password-based login for the root user to enhance security within the isolated LAN.
    *   Use of static **ARP tables** (configurable upon deployment) to mitigate ARP spoofing attacks.
    *   **Defense-in-Depth:** Implementation of local firewall rules using 'iptables' to enforce the principle of least privilege, blocking all traffic except strictly necessary Modbus TCP/IP communication and SSH access via the management IP.
    *   **Network Isolation Strategy:** The system is designed to operate within an isolated local area network (LAN). This physical isolation, combined with static ARP/IP tables and a local firewall, forms the basis of a robust defense-in-depth security posture, crucial for critical infrastructure environments.

## Setup Steps

1.  **Clone the repository:**
    ```bash
    git clone github.com
    cd your-project-name
    ```

2.  **Configure the Workspace:**
    Run the setup script, which will download necessary dependencies and prepare the environment on the mounted USB-HDD.
    ```bash
    ./setup.sh
    ```

3.  **Flash the Image to MicroSD**
    Once the 'sdcard.img' is generated, use a tool like dd (Linux/macOS) or Balena Etcher (all OSes) to flash the image onto your MicroSD card.
    
4.  **Boot the Galileo:**
    Insert the MicroSD car into the intel Galileo Gen 2 and power it on.

## Usage and Functionality

The system is designed to run autonomously on the Intel Galileo Gen 2 board. Upon booting, it automatically mounts the external USB-HDD and starts the necessary daemons (`modbus_daemon`, `lcd_daemon`, etc.).

Interaction with the system is primarily done via SSH for maintenance and monitoring:

*   **System Status:** Use standard `systemctl` commands to check the service status (e.g., `systemctl status domotica-modbus-daemon`).
*   **Logging:** Logs are stored in `/mnt/hdd/logs/`. You can monitor activity using standard Linux tools:
    ```bash
    tail -f /mnt/hdd/logs/modbus.log
    ```
*   **Physical Interface:** The onboard LED indicates error codes, and the SPI LCD displays the current system status (IP address, operational status).

*Note: The user interface via the LCD is still in the early stages of development.*

andard build tools installed
*   A MicroSD Card reader/writer connected to your PC.


## System Updates

The system can be updated in the field using a USB pendrive containing the new `.deb` file.

1.  Copy the `ELI-galileo-vX.Y.Z.deb` file to the root directory of the USB drive.
2.  Insert the USB drive into the Galileo.
3.  The update script will detect .deb package, verify it is newer than the current version installed on the HDD, and proceed with `dpkg -i`.

## Roadmap

The project is currently in active development. Below are our goals for upcoming releases.

- **Version 0.9.0 (Q4 2025): Beta Stage - MVP**
    - [x] Initial repository structure
    - [x] Initial GitHub Actions CI setup
    - [ ] Implement basic GPIO control
    - [ ] Basic LED error signaling
    - [ ] Implement basic SPI control
    - [ ] Basic LCD interface via SPI
    - [ ] Implement basic MODBUS control
    - [ ] Implement basic MODBUS data polling
    - [ ] Implement HDD-USB mounting and logging daemon
    - [ ] '.defconfig' automatic addition to 'buildroot' compilation script
    

- **Version 1.0 (Q4 2026): Initial Release**
    - [ ] Initial GitHub Actions CI/CD setup
    - [ ] SD Card image generation via `./setup.sh` script

- **Future Ideas (No ETA):**
    - [ ] UPS communication for controlled and safe HDD and embedded system shutdown

## Acknowledgements

*   [Buildroot](buildroot.org): For the excellent tool for generating embedded Linux systems.
*   [CppCheck](cppcheck.sourceforge.net): For the static analysis tool and MISRA C support.
*   [GitHub Actions](docs.github.com): For providing the CI/CD automation platform.
*   [Shields.io](shields.io): For the status badges used in this README.md file.

## Contact

Aritz Elgezabal - [LinkedIn Profile URL](https://www.linkedin.com/in/aritzelge/) - aelguezabal010@gmail.com

Project Distribution: [github.com](https://github.com/AritzElge/ELI_galileo)
