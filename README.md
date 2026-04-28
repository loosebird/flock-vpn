# Slint Multi-Platform Python Template

This is a high-performance template for building native desktop applications using Slint for the graphical interface and Python for the business logic. The project is orchestrated by uv and natively compiled for Windows, macOS, and Linux via Nuitka.

## Highlights

- Native Performance: Interface rendered via Rust (Slint) and logic compiled in C (Nuitka).
- Single Source of Truth: Metadata (version, name, icons, company) centralized in `pyproject.toml`.
- Management: Dependencies and virtual environments managed by uv.
- CI/CD: GitHub Actions configured to generate automatic releases with binaries for:
  - Windows: `.exe` (x64 and ARM64);
  - macOS: `.dmg` (Intel and Apple Silicon);
  - Linux: `.flatpak` and `.bin` (x86_64 and AArch64) with Wayland support and `.desktop` files.

## Prerequisites

Before you begin, you will need to have installed:

1. [uv](https://github.com/astral-sh/uv).
2. [GNU Make](https://www.gnu.org/software/make/).
3. C compiler (GCC on Linux, [Xcode](https://developer.apple.com/xcode/) on macOS, or MSVC on Windows).

## How to Use

### 1. Clone and Install
```bash
git clone https://github.com/loosebird/slint-python-template.git
cd slint-python-template
make install
```

> This repository is also set as a public template on GitHub.

### 2. Development
To run the application in development mode (with hot-reload):
```bash
make dev
```

### 3. Local Build
To generate the native binary for your current operating system:
```bash
make build
```

### 4. Validate the Binary
To run the compiled version located in the `dist/` folder:
```bash
make preview
```

## Project Structure
```bash
├── .github/workflows/    # CI/CD pipelines (Build and Release)
├── src/
│   ├── assets/           # Icons (icon.ico, icon.icns, icon.png) and app.desktop
│   ├── ui/               # .slint files (Graphical Interface)
│   └── main.py           # Application entry point
├── Makefile              # Multi-platform command orchestrator
├── pyproject.toml        # Settings, dependencies, and metadata (SSoT)
├── flatpak-manifest.yml  # Flatpak package definition
└── uv.lock               # Dependency version lock file
```

## Customization

```TOML
[project]
name = "MySlintApp"
version = "1.0.0"
description = "A modern GUI application built with Slint and Python."

[tool.app-metadata]
company_name = "Your Company"
app_id = "com.yourcompany.myslintapp"
```
> The icon files in `src/assets/` must keep their original names so that Nuitka and Flatpak can locate them automatically during the build.

## Release and Distribution

The Release pipeline is triggered automatically whenever a new Tag is pushed to the repository:

1. Update the version in `pyproject.toml`.
2. Create a tag and push:
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```
GitHub Actions will generate the assets for Windows, Mac, and Linux in the Releases tab.

## License

This project is licensed under the Apache-2.0 license. See the [LICENSE](https://github.com/loosebird/slint-python-template/blob/main/LICENSE) file for more details.
