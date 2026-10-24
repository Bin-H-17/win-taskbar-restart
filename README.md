# win-taskbar-restart

[中文](#中文) | [English](#english)

## 中文

双击 `restart-taskbar.bat`，重启 Windows 任务栏与桌面外壳（explorer.exe），并重建输入法候选框进程。

任务栏卡死、桌面图标不刷新、托盘点不动时，重启 explorer 通常即可恢复，不必注销或重启系统。

### 运行

双击 `restart-taskbar.bat`。

| 退出码 | 含义 |
|---|---|
| 0 | 任务栏已重启，输入法宿主已重建 |
| 1 | explorer.exe 路径缺失，或多次启动失败（窗口会给出手动启动命令） |

### 实现

- explorer 启动后用 `tasklist` 复核，未启动则最多重试 3 次。
- 延时用 `ping -n <次数> 127.0.0.1`。`timeout` 在标准输入被重定向时不可用，`ping` 不依赖控制台交互。
- 只调用 `%SystemRoot%\System32` 下的系统自带程序：taskkill、tasklist、findstr、ping。不联网，不写注册表，不加载第三方组件。
- 脚本内提示为纯 ASCII 英文：解析与显示不依赖系统代码页，在任何区域设置的 Windows 上都一致，代码页也能直接阅读。

### 系统要求

Windows 10 / 11。

### 许可

MIT。Windows 与 TextInputHost 是 Microsoft 的商标，本项目与 Microsoft 无关联。

## English

Double-click `restart-taskbar.bat` to restart the Windows taskbar and desktop shell (explorer.exe), then rebuild the IME candidate window process.

When the taskbar freezes, desktop icons stop refreshing, or the tray stops responding, restarting explorer usually restores it without signing out or rebooting.

### Two issues the script accounts for

1. explorer.exe does not live in System32. The correct path is `%SystemRoot%\explorer.exe`. Written as `System32\explorer.exe`, the restart kills the shell and the replacement never starts, leaving a black desktop with no taskbar. The script validates the path before touching anything and exits with code 1 when it is missing.
2. Restarting explorer leaves the IME candidate window dead. The candidate box is drawn by `TextInputHost.exe`; once explorer is killed it stays a zombie: keystrokes still register, candidates no longer show. The script kills that process at the end so the system rebuilds it on demand.

### Usage

Double-click `restart-taskbar.bat`.

| Exit code | Meaning |
|---|---|
| 0 | Taskbar restarted, IME host rebuilt |
| 1 | explorer.exe missing, or it failed to start after retries (the window prints a manual command) |

### Implementation

- After starting explorer the script checks with `tasklist` and retries up to 3 times.
- Delays use `ping -n <count> 127.0.0.1`. `timeout` is unavailable when standard input is redirected; `ping` does not depend on console interaction.
- Only stock binaries under `%SystemRoot%\System32` are invoked: taskkill, tasklist, findstr, ping. No network access, no registry writes, no third-party components.
- Messages inside the script are plain ASCII English, so parsing and display do not depend on the system code page, and the file reads correctly on GitHub.

### Requirements

Windows 10 / 11.

### License

MIT. Windows and TextInputHost are Microsoft trademarks; this project is not affiliated with Microsoft.
