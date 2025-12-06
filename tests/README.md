# Unit and Integration Tests

This directory contains the automated test scripts for the application software (Python modules).

---

## 1. Test Scope

The current tests focus on the following areas:
*   The core business logic of the Python daemons (scheduling, data polling, Modbus handling).
*   The robustness of error management and file synchronization (filelock usage).
*   Mocking network interactions to ensure the Modbus client handles connection failures gracefully.

*Note: C/C++ modules are currently tested locally due to the constraints of the Buildroot cross-compilation environment and the need for a lightweight, compatible unit testing framework.*

## 2. Local Execution

You can run the Python unit tests locally on your Host PC (with the required dependencies installed) using pytest:


```bash
# Install pytest and project dependencies (if not already installed)
pip install pytest pymodbus filelock

# Run all tests located in this directory
pytest
```

## 3. Continuous Integration (CI)

These tests are executed automatically on every push and pull request via GitHub Actions. The workflow responsible for running these tests is:
*   `tests.yml`
Additional static code analysis is performed by the `static_analysis.yml` workflow.