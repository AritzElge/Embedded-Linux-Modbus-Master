# Embedded Linux Integration with Intel Galileo Gen 2 (or ELI_galileo)

![Project Status](https://img.shields.io/badge/Project_Status-WIP-blue)

[![Static Analysis](https://github.com/AritzElge/ELI_galileo/actions/workflows/static_analysis.yml/badge.svg)](https://github.com/AritzElge/ELI_galileo/actions/workflows/static_analysis.yml)

This repository presents a master home automation control system designed to operate on an Intel Galileo Gen 2, utilizing MODBUS TCP/IP for managing smart sensors and actuators within the local network.

This project was selected as a technical challenge due to the platform`s discontinued status and lack of official support, optimizing the system for the longevity and reliability of the available hardware.

---

## Table of Contents
- [Key Features](#key-features)
- [Hardware Used](#hardware-used)
- [System Requirements](#system-requirements)
- [Prerequisites](#prerequisites)
- [Technical Features](#technical-features)
- [Software Architecture](#software-architecture)
- [Key Engineering Decisions](#key-engineering-decisions)
- [Project Scope and Requirements](#project-scope-and-requirements)
- [Setup Steps](#setup-steps)
- [Usage and Functionality](#usage-and-functionality)
- [System Updates](#system-updates)
- [Roadmap](#roadmap)
- [Acknowledgements](#acknowledgements)
- [Contributing](CONTRIBUTING.md)
- [License](LICENSE)
- [Contact](#contact)

---    

## Key Features

*   **MODBUS TCP/IP Management:** Full communication and control of smart devices (sensors and actuators) over the local network.
*   **Data Persistence:** Use of an external USB-HDD to store daemons and logs, mitigating the degradation of the OS microSD card.
*   **Secure Updates:** *In-situ* update mechanism via a USB pendrive and package management with version verification.
*   **Visual Diagnostics:** Status LED for error code indication.
*   **Static ARP-Table:** for protection agains ARP-Poisoning. 

## Hardware Used

*   **Mainboard:** Intel Galileo Gen 2 (with CR2032 battery for RTC)
*   **Storage:** MicroSD card (OS) and external USB-HDD (Daemons/Logs)
*   **Network:** Ethernet connection for MODBUS TCP/IP.

## System Requirements
*   Host PC with Linux (for cross-compilation) and `python2` compatibility. (Used VM with Ubuntu 16.04.5 i386)
*   Intel Galileo Gen 2 board.

## Prerequisites

Before running the `./setup.sh` script, ensure the following software dependencies are installed on your **Host PC** (e.g., Ubuntu 16.04.5 i386 VM).

### System Tools & Dependencies

The following base packages are required by Buildroot for successful cross-compilation:

*   `git`: For cloning the repository.
*   `make`, `gcc`, `g++`: The core build tools and C/C++ compilers.
*   `ncurses-dev` (or `ncurses-devel` on RHEL-based systems): Required for the menuconfig interface of Buildroot.
*   `zlib1g-dev`, `libssl-dev`, `libelf-dev`: Various development libraries required by the kernel build process.
*   `rsync`: For syncing files efficiently.
*   `sudo`: Required for flashing the SD card image using `dd`.

You can typically install these using your system's package manager (e.g., `apt install ...` on Debian/Ubuntu systems).

### Python Dependencies

The application software requires Python 3 and several libraries (installed via pip) in the target environment:

*   `python3` and `python3-pip`
*   `filelock`
*   `pymodbus`

These are managed automatically by the Buildroot process once configured correctly.

### Flashing Tools

A tool to write the generated `sdcard.img` to the MicroSD card:

*   `dd` (pre-installed on Linux/macOS)
*   or [Balena Etcher](www.balena.io)

## Technical Features

*   **Master Platform:** Intel Galileo Gen 2 (Quark SoC X1000, Linux).
*   **Languages Used:** Ash shell, Python 3, Native C, Modern C++.
*   **Communication Protocol:** Modbus TCP/IP.
*   **Build System Tool:** **Buildroot** (used to generate the toolchain and the final Linux image).
*   **Coding Standards and Safety:** Hardware communication (`GPIO`, `SPI`) is managed using the **MRAA** library. Code quality and safety are ensured through **continuous static analysis** (using `CppCheck`, `Pylint`, and `ShellCheck`), minimizing common vulnerabilities and ensuring system stability.
*   Full automation of the Continuous Integration (CI) using **GitHub Actions**.

## Software Architecture

* **Modular Architecture:** Application software is decoupled from the base operating system.
* **Package Management:** Daemons are packaged as standard `.ipk` packages that facilitate dependency management and incremental updates.

The system consists of several daemons that communicate internally:

*   `error_code_blink` (C): Provides continuous **heartbeat signaling** (1Hz pulse) when the system is healthy and switches to specific LED blink patterns (long/short combinations) for detailed error reporting as a fallback mechanism.
*   `schedule_daemon` (Python 3): Manages the main scheduler for actuator actions (executed via `start_schedule_daemon.sh`).
*   `polling_daemon` (Python 3): Manages the loop for sensor data acquisition (executed via `start_polling_daemon.sh`).
*   `modbus_client` (Python 3 Module): Manages network communication.

## Key Engineering Decisions

*   **Hybrid CI/CD Strategy:** DDecision not to compile the entire Buildroot image in the cloud due to the performance and time limitations of public CI/CD runners. The resulting toolchain is generated locally. The GitHub Actions pipeline is exclusively focused on static code validation (`Pylint`, `CppCheck`, `ShellCheck`) to ensure quality before the final local compilation.
*   **Reproducibility of the Buildroot:** Use of bash scripts and `defconfig` files to automate the complete configuration of the Buildroot workspace, ensuring reproducible builds locally without manual intervention.
*   **Optimal Language Selection (Multi-Level Approach):** Decision to select the most suitable language for each task based on criticality and required performance. 
    *   **C/C++:** Used for performance-critical tasks like hardware drivers (error blinking), leveraging the **MRAA library** for simplified and portable control.
    *   **Python:** Used for complex logic tasks and system integration (Modbus comms, scheduling) where development speed is key.
    *   **Ash Shell/Bash:** Used exclusively for system initialization, setup scripts, and wrapper execution.
*   **Resource Management:** Python's built-in features and robust libraries (filelock, for example) are used for safe management of synchronization and inter-process communication.
*   **Timekeeping and Data Integrity:** Integration of a **CR2032 battery backup** for the Real-Time Clock (RTC) on the Galileo Gen 2 board. This ensures accurate timestamping of all system logs and events, which is critical for debugging, security auditing, and reliable data correlation in an isolated environment without constant NTP synchronization.
*   **Network Security:** 
    *   **Secure Access:** SSH access is restricted to public/private key authentication only, disabling password-based login for the root user to enhance security within the isolated LAN.
    *   Use of static **ARP tables** (configurable upon deployment) to mitigate ARP spoofing attacks.
    *   **Defense-in-Depth:** Implementation of local firewall rules using `iptables` to enforce the principle of least privilege, blocking all traffic except strictly necessary Modbus TCP/IP communication and SSH access via the management IP.
    *   **Network Isolation Strategy:** The system is designed to operate within an isolated local area network (LAN). This physical isolation, combined with static ARP/IP tables and a local firewall, forms the basis of a robust defense-in-depth security posture, crucial for critical infrastructure environments.

## Project Scope and Requirements

The scope of this project is defined by a set of functional and non-functional requirements that address the hardware limitations and operational environment of the Intel Galileo Gen 2.

A detailed specification of the system requirements can be found in the documentation directory:

*   [System Requirements Specification (SRS)](docs/requirements.md)

## Setup Steps

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/AritzElge/ELI_galileo
    cd ELI_galileo
    ```

2.  **Configure the Workspace:**
    Run the setup script locally on your Host PC. This script automates the configuration of the Buildroot workspace, downloads all necessary toolchains and dependencies, and compiles the system image (`sdcard.img`) and application packages (`.ipk`).
    ```bash
    ./setup.sh
    ```

3.  **Flash the Image to MicroSD**
    Once the `sdcard.img` is generated, use a tool like dd (Linux/macOS) or Balena Etcher (all OSes) to flash the image onto your MicroSD card.
    ```
    # Example using dd (ensure you replace `sdx` with your actual SD card device)
    sudo dd if=sdcard.img of=/dev/sdx bs=4M status=progress
    ```
    *(Note: The application software expects a secondary USB-HDD to be connected to the Galileo board upon boot for logging and primary OS functionality.)*

4.  **Boot the Galileo:**
    Insert the MicroSD car into the intel Galileo Gen 2 and power it on.

## Usage and Functionality

The system is designed to run autonomously on the Intel Galileo Gen 2 board. Upon booting, it automatically mounts the external USB-HDD and starts the necessary daemons.

Interaction with the system is primarily done via SSH for maintenance and monitoring:

*   **System Status:** Use standard `systemctl` commands (or equivalent init system commands in your specific Buildroot configuration) to check the service status (e.g., `systemctl status domotica-schedule-daemon`).
*   **Logging:** Logs are stored in `/mnt/hdd/logs/`. You can monitor activity using standard Linux tools:
    ```
    bash
    tail -f /mnt/hdd/logs/modbus.log
    ```
*   **Physical Interface:** The onboard LED provides heartbeat signaling and displays specific error codes (see `error_code_blink` daemon documentation). 

## System Updates

The system can be updated in the field using a USB pendrive containing the new application packages. This method facilitates rigorous version control and deployment in environments with limited or no network connectivity.

1.  Copy the `ELI-galileo-vX.Y.Z.ipk` file to the root directory of the USB drive.
2.  Insert the USB drive into the Galileo board while it is running.
3.  The update script will detect the new package, verify its integrity, and check that it is newer than the version currently installed on the system's primary HDD partition.
4.  The script will then safely install the .ipk package, managing dependencies automatically.

## Roadmap

The project is currently in active development. Below are the goals for upcoming releases.

- **Version 0.9.0 (Q4 2025): Beta Stage - MVP**
    - [x] Initial repository structure
    - [x] Initial GitHub Actions CI setup
    - [x] Implement basic GPIO control
    - [x] Basic LED error signaling
    - [x] Implement basic MODBUS control
    - [x] Implement basic MODBUS data polling
    - [x] Implement basic MODBUS scheduled actions.
    - [X] Implement HDD-USB mounting and daily-logging daemon
    - [ ] Automated Build Reproducibility via `.config` integration
    - [ ] SD Card image generation via `./setup.sh` script
    - [ ] Implement **automated Unit Testing** (e.g., Pytest for Python modules)

- **Version 1.0 (Q1 2026): Initial Release**
    - [ ] `ipk` package management for Robust Field Updates
    - [ ] Implement secure SSH access (key-only authentication, disabled root password)
    - [ ] Configure static ARP tables and iptables firewall rules
    - [ ] Reliability Target: Implement automatic system health-check and watchdog service

- **Future Ideas (No ETA):**
    - [ ] Buildroot -> Yocto
    - [ ] Refactor to C/C++
    - [ ] Refactor MRAA to Linux Standard API
    - [ ] SSH Tunnelling for Encrypted Modbus Communication

## Acknowledgements

*   [Buildroot](buildroot.org): For the excellent tool for generating embedded Linux systems.
*   [ShellCheck](www.shellcheck.net): For the static analysis tool for shell script best practices.
*   [CppCheck](cppcheck.sourceforge.net): For the static analysis tool and MISRA C support.
*   [Pylint](pylint.org): For the static analysis tool for Python code quality enforcement.
*   [Pymodbus](https://github.com/pymodbus-dev/pymodbus): For the Python Modbus TCP/IP client/server library.
*   [Filelock](pylint.org): For the platform-independent file lock library for IPC synchronization.
*   [MRAA](iotdk.intel.com): For the low-level hardware abstraction library for GPIO/SPI control.
*   [GitHub Actions](docs.github.com): For providing the CI/CD automation platform.
*   [Shields.io](shields.io): For the status badges used in this README.md file.

## Contact

Aritz Elgezabal - [LinkedIn Profile URL](https://www.linkedin.com/in/aritzelge/) - aelguezabal010@gmail.com

Project Distribution: [github.com](https://github.com/AritzElge/ELI_galileo)
