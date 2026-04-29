import slint
import os
from core.system_info import get_os, get_arch

# Forces the FemtoVG renderer.
os.environ["SLINT_BACKEND"] = "renderer-femtovg-wgpu"

os.environ["SLINT_STYLE"] = "native"

def get_resource_path(relative_path):
    """ Ensures the path works both in the terminal and in the compiled Nuitka binary """
    base_path = os.path.abspath(os.path.dirname(__file__))
    return os.path.join(base_path, relative_path)

def main():
    # Locate the .slint file inside the ui/ folder.
    ui_path = get_resource_path(os.path.join("ui", "main.slint"))
    ui = slint.load_file(ui_path)
    app = ui.MainWindow()

    os_system = get_os()
    arch = get_arch()
    app.system_info = f"You are on {os_system} with {arch} architecture."

    def increment():
        app.counter += 1
        print(f"Value: {app.counter}")

    app.process_click = increment
    app.run()

if __name__ == "__main__":
    main()
