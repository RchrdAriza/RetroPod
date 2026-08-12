#include "utils.h"

#include <flutter_windows.h>
#include <io.h>
#include <stdio.h>
#include <windows.h>

#include <iostream>

namespace {
    constexpr wchar_t kWindowSizeRegistryKey[] = L"Software\\RetroPod";
    constexpr wchar_t kWindowWidthValueName[] = L"WindowWidth";
    constexpr wchar_t kWindowHeightValueName[] = L"WindowHeight";
    constexpr wchar_t kWindowSizeIsLogicalValueName[] = L"WindowSizeIsLogical";
}

void CreateAndAttachConsole() {
  if (::AllocConsole()) {
    FILE *unused;
    if (freopen_s(&unused, "CONOUT$", "w", stdout)) {
      _dup2(_fileno(stdout), 1);
    }
    if (freopen_s(&unused, "CONOUT$", "w", stderr)) {
      _dup2(_fileno(stdout), 2);
    }
    std::ios::sync_with_stdio();
    FlutterDesktopResyncOutputStreams();
  }
}

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line arguments to UTF-8 for the Engine to use.
  int argc;
  wchar_t** argv = ::CommandLineToArgvW(::GetCommandLineW(), &argc);
  if (argv == nullptr) {
    return std::vector<std::string>();
  }

  std::vector<std::string> command_line_arguments;

  // Skip the first argument as it's the binary name.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }

  ::LocalFree(argv);

  return command_line_arguments;
}

std::optional<StoredWindowSize> LoadStoredWindowSize() {
    HKEY key_handle;
    if (RegOpenKeyEx(HKEY_CURRENT_USER, kWindowSizeRegistryKey, 0, KEY_READ,
                     &key_handle) != ERROR_SUCCESS) {
        return std::nullopt;
    }

    DWORD width_value = 0;
    DWORD width_size = sizeof(width_value);
    if (RegQueryValueEx(key_handle, kWindowWidthValueName, nullptr, nullptr,
                        reinterpret_cast<LPBYTE>(&width_value),
                        &width_size) != ERROR_SUCCESS) {
        RegCloseKey(key_handle);
        return std::nullopt;
    }

    DWORD height_value = 0;
    DWORD height_size = sizeof(height_value);
    if (RegQueryValueEx(key_handle, kWindowHeightValueName, nullptr, nullptr,
                        reinterpret_cast<LPBYTE>(&height_value),
                        &height_size) != ERROR_SUCCESS) {
        RegCloseKey(key_handle);
        return std::nullopt;
    }

    DWORD logical_flag = 0;
    DWORD logical_flag_size = sizeof(logical_flag);
    bool is_physical = true;
    if (RegQueryValueEx(key_handle, kWindowSizeIsLogicalValueName, nullptr,
                        nullptr, reinterpret_cast<LPBYTE>(&logical_flag),
                        &logical_flag_size) == ERROR_SUCCESS) {
        is_physical = logical_flag != 1;
    }

    RegCloseKey(key_handle);

    if (width_value == 0 || height_value == 0) {
        return std::nullopt;
    }

    return StoredWindowSize{static_cast<int>(width_value),
                            static_cast<int>(height_value), is_physical};
}

void SaveWindowSize(const StoredWindowSize& size) {
    if (size.width <= 0 || size.height <= 0) {
        return;
    }

    HKEY key_handle;
    if (RegCreateKeyEx(HKEY_CURRENT_USER, kWindowSizeRegistryKey, 0, nullptr,
                       REG_OPTION_NON_VOLATILE, KEY_WRITE, nullptr, &key_handle,
                       nullptr) != ERROR_SUCCESS) {
        return;
    }

    DWORD width_value = static_cast<DWORD>(size.width);
    RegSetValueEx(key_handle, kWindowWidthValueName, 0, REG_DWORD,
                  reinterpret_cast<const BYTE*>(&width_value),
                  sizeof(width_value));

    DWORD height_value = static_cast<DWORD>(size.height);
    RegSetValueEx(key_handle, kWindowHeightValueName, 0, REG_DWORD,
                  reinterpret_cast<const BYTE*>(&height_value),
                  sizeof(height_value));

    DWORD logical_flag = size.is_physical ? 0 : 1;
    RegSetValueEx(key_handle, kWindowSizeIsLogicalValueName, 0, REG_DWORD,
                  reinterpret_cast<const BYTE*>(&logical_flag),
                  sizeof(logical_flag));

    RegCloseKey(key_handle);
}

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  unsigned int target_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      -1, nullptr, 0, nullptr, nullptr)
    -1; // remove the trailing null character
  int input_length = (int)wcslen(utf16_string);
  std::string utf8_string;
  if (target_length == 0 || target_length > utf8_string.max_size()) {
    return utf8_string;
  }
  utf8_string.resize(target_length);
  int converted_length = ::WideCharToMultiByte(
      CP_UTF8, WC_ERR_INVALID_CHARS, utf16_string,
      input_length, utf8_string.data(), target_length, nullptr, nullptr);
  if (converted_length == 0) {
    return std::string();
  }
  return utf8_string;
}
