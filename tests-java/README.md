# UI tests (Java)

Automated browser tests for the static HTML demos in the parent repository. Tests use [Selenide](https://selenide.org/) and JUnit 5 to open pages in Chrome and verify form interactions.

## Prerequisites

- Java 21
- Google Chrome installed locally

## Run tests

From this directory:

```bash
cd tests-java
./gradlew test
```

Run a single test class:

```bash
./gradlew test --tests LoginTests
./gradlew test --tests TextBoxTests
./gradlew test --tests RegistrationTests
```

Open the HTML report after a run:

```bash
open build/reports/tests/test/index.html
```

## What is tested

| Test class           | Page                         | Scenarios |
|----------------------|------------------------------|-----------|
| `LoginTests`         | `login.html`                 | Successful login, wrong password |
| `TextBoxTests`       | `text-box.html`              | Fill form and verify output |
| `RegistrationTests`  | `automation-practice-form.html` | Full registration form (local copy and [demoqa.com](https://demoqa.com/automation-practice-form)) |

Pages are loaded from the repository root via `Configuration.baseUrl` in `TestBase` (set to `../`). Keep the HTML files in the parent folder up to date when changing selectors or behavior.

## Project layout

```
tests-java/
├── build.gradle
├── gradlew
├── gradlew.bat
├── gradle/wrapper/
└── src/test/
    ├── java/
    │   ├── TestBase.java          # Shared Selenide configuration
    │   ├── LoginTests.java
    │   ├── TextBoxTests.java
    │   └── RegistrationTests.java
    └── resources/
        └── img/1.png              # Sample file for upload tests
```

## Configuration

Browser settings live in `TestBase.java`:

- **Browser:** Chrome (default)
- **Window size:** 1920×1280
- **Base URL:** parent directory (`../`), so `open("/login.html")` resolves to `login.html` at the repo root

Uncomment options in `TestBase` to switch to headless mode, change timeouts, or pin a Chrome version.

## Dependencies

- Selenide 7.16.2
- JUnit Jupiter 5.11.4
