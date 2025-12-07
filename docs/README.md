# Technical Documentation for the ELI_galileo Project

This directory contains the detailed technical documentation, specifications, and operational manuals for the embedded system.

---

## 1. Hardware Specifications and Datasheets

*   [Intel Galileo Gen 2 Official Documentation (Intel Archive)](https://www.intel.com/content/dam/www/public/us/en/documents/datasheets/galileo-g2-datasheet.pdf)
*   [Intel Quark SoC X1000 Datasheet (Revision 002)](https://www.intel.com/content/dam/support/us/en/documents/processors/quark/sb/quarkdatasheetrev02.pdf)
*   [Intel Quark SoC X1000 Specification Update](https://cdrdv2-public.intel.com/329677/quark-x1000-spec-update.pdf)
*   [Intel Galileo Gen 2 Board schematics (via Adafruit)](https://cdn-shop.adafruit.com/datasheets/Galileo_Gen2_Schematic.pdf)
*   [Controlador LCD SPI ST7920](https://www.hpinfotech.ro/ST7920.pdf)

*Note: The technical specification for the proprietary Modbus interface and custom modules is currently pending public documentation.

## 2. System Architecture
    
*   [Hardware Connection Schematic (SPI Pinout)](hardware_schematic.pdf)
*   **Data Flow Diagram and Software Architecture:**
```mermaid
graph TD
    %% Define the external systems
    A[Sensors/Actuators Modbus TCP/IP]
    
    %% Define the software components (Daemons and Scripts)
    D(start_polling_daemon.sh)
    E(start_schedule_daemon.sh)
    F(start_lcd_daemon.sh)
    
    G(polling_daemon.py)
    H(schedule_daemon.py)
    I(lcd_daemon)
    J(error_code_blink.c)
    
    %% Define hardware resources and IPC
    K[USB HDD - Logs/Data] 
    L[Status files IPC]
    M(LED de Estado)
    N(LCD SPI Screen)

    %% Define data flow
    A -- Ethernet/Modbus --> G

    G -- Write Logs --> K
    H -- Write Logs --> K
    I -- Write Logs --> K

    D -- Launch and Monitor --> G
    E -- Launch and Monitor --> H
    F -- Launch and Monitor --> I
    
    G -- Update Status --> L
    H -- Update Status --> L
    I -- Update Status --> L
    
    L -- Read Status periodically --> J
    J -- Controls --> M
    I -- Controls --> N

    %% Styles
    style A fill:#FF4500,stroke:#333,stroke-width:2px,color:#FFFFFF
    style D fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style E fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style F fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style G fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style H fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style I fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style J fill:#00008B,stroke:#333,stroke-width:2px,color:#FFFFFF
    style K fill:#32CD32,stroke:#333,stroke-width:2px,color:#FFFFFF
    style L fill:#32CD32,stroke:#333,stroke-width:2px,color:#FFFFFF
    style M fill:#FF4500,stroke:#333,stroke-width:2px,color:#FFFFFF
    style N fill:#D3D3D3,stroke:#333,stroke-width:2px,color:#00008B
```


## 3. Operational Manuals and Procedures

*   [Initial Deployment and Network Configuration Manual](deployment_guide.md)
*   [Operations and Troubleshooting Guide (LED Error Codes)](ops_guide.md)
*   [Offline Firmware Update Procedure](update_procedure.md)
