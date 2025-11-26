# Contributing to the Embedded Linux Modbus Master
Thank you for your interest in contributing to this project. Contributions that help the reliability, safety and functionality of the software for the Intel Galileo Gen 2 platform are welcomed.

To maintain a professional and traceable engineering standard (crucial for embedded), the following of these guidelines is asked.

## 1. Code of conduct
Adhere to professional and respectful enviroment. Be excelent to each other.

## 2. Development Workflow (GitFlow)

1. **Fork** the repository.
2. **Clone** your fork locally
3. **Create a new branch** for your feature or bugfix (e.g., 'feature/add-temperature-sensor' or 'bugfix/fix-i2c-daemon-crash').
4. **Commit** your changes following the commit message guidelines below.
5. **Push** your changes to your fork.
6. **Open a Pull Request** (PR) against the 'main' branch of this repository,

## 3. Commit Message Guidelines

Standarized commit messages to ensure clarity and traceability of changes are enforces. The use of Conventional Commits specification is encouraged to be used.

**Format:** '\<type\>(\<scope\>): \<description\>'

* 'type': Must be one of the following:
  * 'feat': A new feature or enhacement.
  * 'fix': A bug fix.
  * 'docs': Documentation only changes.
  * 'style': Changes that do not affect the meaning of the code (whitespace, formatting, missing semicolons, etc).
  * 'refactor': A code change that neither fixes a bug nor adds a feature.
  * 'test': Adding a missing test or correcting existing tests.
  * 'chore': Maintenance tasks, build system updates, etc.
* 'scope': Optional. The specific module affected (e.g., 'i2c-daemon', 'buildroot-script', 'docs').
* 'description': A short, imperative tense description of the change.

**Examples:**
* 'feat(i2c-daemon): Add support for the new sensor model'
* 'docs(readme): Update CI badge URL'
* 'fix(buildroot-script): Ensure .deb artifact is downloaded correctly'

## 4. Pull Request (PR) Checklist

Before submitting your Pull Request, please ensure the following:

* [ ] **Code Builds Successfully:** Your changes compile correctly using the cross-compilation toolchain.
* [ ] **CI Pipeline passes:** The GitHub Actions workflow must pass all steps (static analysis, unit tests, packaging) successfully.
* [ ] **Unit Tests Added/Passed:** You have added relevant unit tests for new features/fixes, and all existing tests pass.
* [ ] **Documentation Updated:** 'README.md' por other relevant documentation is updated to reflect your changes.
* [ ] **MISRA Compliance:** C/C++ code adheres to MISRA C:2012 guidelines (checked by CppCheck in CI).

## 5. Reporting Issues

If you find a bug or have a feature request, please open a new issue.

Thank you for your contribution!
