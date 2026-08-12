#include <cmath>
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(400, 800);
  if (auto stored_size = LoadStoredWindowSize()) {
    int restored_width = stored_size->width;
    int restored_height = stored_size->height;
    if (stored_size->is_physical) {
        const POINT target_point = {static_cast<LONG>(origin.x),
                                    static_cast<LONG>(origin.y)};
        HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
        UINT dpi = 96;
        if (monitor != nullptr) {
            dpi = FlutterDesktopGetDpiForMonitor(monitor);
        }
        double scale_factor = dpi / 96.0;
        if (scale_factor <= 0.0) {
            scale_factor = 1.0;
        }
        restored_width = static_cast<int>(std::round(restored_width / scale_factor));
        restored_height = static_cast<int>(std::round(restored_height / scale_factor));
        SaveWindowSize(StoredWindowSize{restored_width, restored_height, false});
    }
    size = Win32Window::Size(restored_width, restored_height);
  }
  if (!window.Create(L"RetroPod", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
