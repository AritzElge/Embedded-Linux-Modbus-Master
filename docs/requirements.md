# System Requirements Specification (SRS)

This document describes the functional and non-functional requirements (F/NF) for the ELI_galileo embedded home automation control system.

## 1. Functional Requirements (FR)
*Functional requirements describe what the system must do.*

*   **FR-001**	The system shall be able to boot and load all operational daemons from persistent storage (USB-HDD).	**Critical**
*   **FR-002**	The system shall establish full MODBUS TCP/IP communication with slave devices on the local network.	**Critical**
*   **FR-003**	The system shall perform periodic polling of configured smart sensors.	**High**
*   **FR-004**	The system shall execute scheduled actions on smart actuators according to the defined configuration.	**High**
*   **FR-005**	The system shall display the current operational status and key sensor data on the SPI LCD screen.	**Medium**
*   **FR-006**	The system shall log all operational events, errors, and sensor readings to dedicated log files.	**Critical**
*   **FR-007**	The system shall support application software updates via an offline USB device with version verification.	**Critical**

## 2. Non-Functional Requirements (NFR)
*Non-functional requirements describe how the system should be (quality, performance, security).*

*   **NFR-001**	The maximum system boot time (from power-on to "Healthy" LED status) shall not exceed 3 minutes (180 seconds).	**Performance**
*   **NFR-002**	The system shall operate autonomously without human intervention or constant NTP synchronization.	**Availability**
*   **NFR-003**	The system shall mitigate data corruption and OS failures by prioritizing log storage on the external HDD.	**Resilience**
*   **NFR-004**	Remote access (SSH) shall be restricted to public/private key authentication only.	**Security**
*   **NFR-005**	The system shall use static ARP tables and iptables to implement a "Defense-in-Depth" strategy on the local network.	**Security**
*   **NFR-006**	The system shall use the RTC battery (CR2032) to ensure accurate timestamping of all logs.	**Data Integrity**
*   **NFR-007**	The system shall provide a fallback diagnostic mechanism using LED error codes if the network or LCD fails.	**Maintainability**



