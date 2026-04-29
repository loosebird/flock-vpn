import platform

def get_os():
    """Returns the standardized Operating System name."""
    os_name = platform.system()
    if os_name == "Darwin":
        return "macOS"
    return os_name

def get_arch():
    """Returns to the standardized processor architecture."""
    arch = platform.machine()
    if arch in ["AMD64", "x86_64"]:
        return "x64"
    elif arch in ["aarch64", "arm64"]:
        return "ARM64"
    return arch
