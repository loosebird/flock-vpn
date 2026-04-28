APP_NAME := $(shell grep -E '^name\s*=' pyproject.toml | cut -d '"' -f2)
APP_VERSION := $(shell grep -E '^version\s*=' pyproject.toml | cut -d '"' -f2)
APP_DESC := $(shell grep -E '^description\s*=' pyproject.toml | cut -d '"' -f2)
COMPANY_NAME := $(shell grep -E '^company_name\s*=' pyproject.toml | cut -d '"' -f2)
APP_ID := $(shell grep -E '^app_id\s*=' pyproject.toml | cut -d '"' -f2)

MAIN_SCRIPT = src/main.py
ICON_WIN = src/assets/icon.ico
ICON_MAC = src/assets/icon.icns
ICON_LINUX = src/assets/icon.png

ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    RAW_ARCH := $(PROCESSOR_ARCHITECTURE)
else
    DETECTED_OS := $(shell uname -s)
    RAW_ARCH := $(shell uname -m)
endif

ifeq ($(DETECTED_OS),Windows)
    ifeq ($(RAW_ARCH),AMD64)
        ARCH := x64
    else ifeq ($(RAW_ARCH),x86_64)
        ARCH := x64
    else ifeq ($(RAW_ARCH),arm64)
        ARCH := arm64
    else
        ARCH := $(RAW_ARCH)
    endif
else ifeq ($(DETECTED_OS),Darwin)
    ifeq ($(RAW_ARCH),x86_64)
        ARCH := x86_64
    else ifeq ($(RAW_ARCH),arm64)
        ARCH := arm64
    else
        ARCH := $(RAW_ARCH)
    endif
else ifeq ($(DETECTED_OS),Linux)
    ifeq ($(RAW_ARCH),x86_64)
        ARCH := x86_64
    else ifeq ($(RAW_ARCH),aarch64)
        ARCH := aarch64
    else
        ARCH := $(RAW_ARCH)
    endif
endif

NUITKA_BASE_FLAGS = --assume-yes-for-downloads --standalone --onefile --include-data-dir=src/ui=ui --output-dir=dist

ifeq ($(DETECTED_OS),Darwin)
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).dmg
    NUITKA_FLAGS = --standalone --include-data-dir=src/ui=ui --output-dir=dist \
        --macos-create-app-bundle \
        --macos-app-name="$(APP_NAME)" \
        --macos-app-version="$(APP_VERSION)" \
        --macos-app-icon="$(ICON_MAC)" \
        --output-filename="$(APP_NAME)"
    POST_BUILD_CMD = @if [ -d "dist/main.app" ]; then mv "dist/main.app" "dist/$(APP_NAME).app"; fi; \
                     if [ -d "dist/$(APP_NAME).app" ]; then hdiutil create -volname "$(APP_NAME)" -srcfolder "dist/$(APP_NAME).app" -ov -format UDZO "dist/$(TARGET_FILE)"; fi
else ifeq ($(DETECTED_OS),Linux)
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).bin
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo "Linux build complete: $(TARGET_FILE)"
else
    TARGET_FILE = $(APP_NAME)-v$(APP_VERSION)-$(ARCH).exe
    NUITKA_FLAGS = $(NUITKA_BASE_FLAGS) \
        --windows-disable-console \
        --windows-product-name="$(APP_NAME)" \
        --windows-product-version="$(APP_VERSION)" \
        --windows-company-name="$(COMPANY_NAME)" \
        --windows-file-description="$(APP_DESC)" \
        --windows-icon-from-ico="$(ICON_WIN)" \
        --output-filename="$(TARGET_FILE)"
    POST_BUILD_CMD = @echo "Windows build complete: $(TARGET_FILE)"
endif

.PHONY: info install dev build clean

info:
	@echo "Build Info"
	@echo "App: $(APP_NAME) v$(APP_VERSION)"
	@echo "Description: $(APP_DESC)"
	@echo "Company Name: $(COMPANY_NAME)"
	@echo "ID: $(APP_ID)"
	@echo "OS: $(DETECTED_OS)"
	@echo "Architecture: $(RAW_ARCH)"
	@echo "Target File: $(TARGET_FILE)"

install:
	uv sync

dev:
	uv run $(MAIN_SCRIPT)

build: info
	uv run python -m nuitka $(NUITKA_FLAGS) $(MAIN_SCRIPT)
	$(POST_BUILD_CMD)

preview:
	@echo "Launching Compiled App"
ifeq ($(DETECTED_OS),Windows)
	@./dist/$(TARGET_FILE)
else ifeq ($(DETECTED_OS),Darwin)
	@open dist/$(APP_NAME).app
else
	@./dist/$(TARGET_FILE)
endif

clean:
	rm -rf dist build .venv
